---
id: ds-fast-block-list
title: '更快的块状链表'
category: '数据结构'
subcategory: '分块'
tags: ["块状链表","树状数组","分块","卡常"]
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-25
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，保留原文结构与表述。
之前我写过一篇文章：[浅谈一种黑科技——索引树优化块状链表](https://www.luogu.com.cn/article/h17wdap7)，说人话就是对于每个块的长度建一棵线段树。

今天去 P6136 看了一下，怎么有[高手](https://www.luogu.com.cn/record/237192574)卡到 2.5s 了？

翻了下代码，发现最大的改变就是把线段树变成了树状数组。于是花 eps 时间实现了这个东西，又花 eps 时间写了一个对读入分块的 `extend` 函数，交上去，不是怎么 2.7s。

换成 C++20，这下 2.52s 了。

## 原理

考虑一下普通块链慢在哪里。

设块长为 $B$。通过记录块内最大值，插入删除找块是 $O(\log \dfrac{n}{B})$ 的，块内插入删除是 $O(B)$ 的。分裂合并的复杂度是 $O(B+\dfrac{n}{B})$ 的。

考虑到分裂合并不是很多，$B$ 应该取一个 $O(\sqrt{n})$ 级别又小于 $\sqrt{n}$ 的数。这部分没法优化了。

思考找数的时候怎么找。传统的方法就是一个块一个块扫过去，复杂度 $O(\dfrac{n}{B})$。于是为了让 $O(B)$ 和 $O(\dfrac{n}{B})$ 平衡，取 $B=\sqrt{n}$，复杂度 $O(n\sqrt{n})$，FHQ 都跑不过。

用一个树状数组 / 线段树维护每个块的块长，发生修改时暴力重构。找数在线段树上二分或者树状数组上倍增即可。复杂度 $O(\log \dfrac{n}{B})$。重构复杂度 $O(\dfrac{n}{B})$。

总体算下来复杂度 $O(B+\dfrac{n}{B})$。通过微调块长，重构次数原低于 $\sqrt{n}$，于是 $B$ 取一个小于 $\sqrt{n}$ 的数没有问题。

实测 $B=150$ 时，在 C++20 且使用树状数组优化下最快。

## 板子

### 树状数组版本

```cpp
template <class T>
struct sorted_vector {
private:
	static constexpr int DEFAULT_LOAD_FACTOR = 150;
	int len, load;
	std::vector<std::vector<T>> lists;
	std::vector<T> maxes, index;

	void expand(int pos) {
		if ((int) lists[pos].size() > (load << 1)) {
			std::vector<T> half(lists[pos].begin() + load, lists[pos].end());
			lists[pos].erase(lists[pos].begin() + load, lists[pos].end());
			maxes[pos] = lists[pos].back();
			lists.insert(lists.begin() + pos + 1, half);
			maxes.insert(maxes.begin() + pos + 1, half.back());
			index.clear();
		} else if (!index.empty()) {
			int n = index.size();
			for (int i = pos + 1; i < n; i += (i & -i)) index[i]++;
		}
	}

	void build_index() {
		int n = lists.size();
		index.resize(n, 0);
		for (int i = 1; i < n; i++) {
			index[i] += lists[i - 1].size();
			if (i + (i & -i) < n) index[i + (i & -i)] += index[i];
		}
	}

	std::pair<int, int> pos(int idx) {
		if (idx < (int) lists[0].size()) return std::make_pair(0, idx);
		if (index.empty()) build_index();
		int p = 0, n = index.size();
		for (int i = std::__lg(n); i >= 0; i--) {
			if (p + (1 << i) < n && idx >= index[p + (1 << i)]) idx -= index[p + (1 << i)], p += 1 << i;
		}
		return std::make_pair(p, idx);
	}
	int loc(int pos, int idx) {
		if (pos == 0) return idx;
		if (index.empty()) build_index();
		for (; pos; pos -= (pos & -pos)) idx += index[pos];
		return idx;
	}
public:
	sorted_vector() : len(0), load(DEFAULT_LOAD_FACTOR) {}
	template <class It> sorted_vector(const It& bg, const It& ed)
	: len(0), load(DEFAULT_LOAD_FACTOR) {extend(bg, ed);}
	int size() const {return len;}
	bool empty() const {return maxes.empty();}

	void clear() {len = 0, lists.clear(), maxes.clear(), index.clear();}

	void add(const T& val) {
		if (!maxes.empty()) {
			int pos = std::upper_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
			if (pos == (int) maxes.size()) pos--, lists[pos].emplace_back(val), maxes[pos] = val;
			else lists[pos].insert(std::upper_bound(lists[pos].begin(), lists[pos].end(), val), val);
			expand(pos);
		} else {
			lists.emplace_back(1, val), maxes.emplace_back(val);
		} len++;
	}
  template <class It> void extend(const It& bg, const It& ed) {
		if ((ed - bg) * 4 < len) {
			for (It it = bg; it != ed; it++) add(*it);
			return;
		}
		vector<T> a(bg, ed);
		for (const auto& vec : lists) a.insert(a.end(), vec.begin(), vec.end());
		std::sort(a.begin(), a.end());
		clear(), len = a.size();
		for (int pos = 0; pos < len; pos += load) {
			std::vector<T> vec(a.begin() + pos, a.begin() + std::min(len, pos + load));
			lists.emplace_back(vec), maxes.emplace_back(vec.back());
		}
	}

	bool erase(const T& val) {
		if (maxes.empty()) return false;
		int pos = std::lower_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (pos == (int) maxes.size()) return false;
		int idx = std::lower_bound(lists[pos].begin(), lists[pos].end(), val) - lists[pos].begin();
		if (lists[pos][idx] != val) return false;

		lists[pos].erase(lists[pos].begin() + idx), len--;
		int n = lists[pos].size();
		if (n > (load >> 1)) {
			maxes[pos] = lists[pos].back();
			if (!index.empty()) {
				int n = index.size();
				for (int i = pos + 1; i < n; i += (i & -i)) index[i]--;
			}
		} else if (lists.size() > 1) {
			if (!pos) pos++;
			int pre = pos - 1;
			lists[pre].insert(lists[pre].end(), lists[pos].begin(), lists[pos].end());
			maxes[pre] = lists[pre].back();
			lists.erase(lists.begin() + pos), maxes.erase(maxes.begin() + pos);
			index.clear(), expand(pre);
		} else if (n > 0) {
			maxes[pos] = lists[pos].back();
		} else {
			lists.erase(lists.begin() + pos), maxes.erase(maxes.begin() + pos);
			index.clear();
		} return true;
	}

	T operator[] (int idx) {
		auto pir = pos(idx);
		return lists[pir.first][pir.second];
	}

	int lower_bound(const T& val) {
		if (maxes.empty()) return 0;
		int pos = std::lower_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (pos == (int) maxes.size()) return len;
		return loc(pos, std::lower_bound(lists[pos].begin(), lists[pos].end(), val) - lists[pos].begin());
	}
	int upper_bound(const T& val) {
		if (maxes.empty()) return 0;
		int pos = std::upper_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (pos == (int) maxes.size()) return len;
		return loc(pos, std::upper_bound(lists[pos].begin(), lists[pos].end(), val) - lists[pos].begin());
	}
	int count(const T& val) {
		if (maxes.empty()) return 0;
		int l = std::lower_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (l == (int) maxes.size()) return 0;
		int r = std::upper_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		int x = std::lower_bound(lists[l].begin(), lists[l].end(), val) - lists[l].begin();
		if (r == (int) maxes.size()) return len - loc(l, x);
		int y = std::upper_bound(lists[r].begin(), lists[r].end(), val) - lists[r].begin();
		if (l == r) return y - x;
		return loc(r, y) - loc(l, x);
	}
	bool contains(const T& val) {
		if (maxes.empty()) return false;
		int pos = std::lower_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (pos == (int) maxes.size()) return false;
		int idx = std::lower_bound(lists[pos].begin(), lists[pos].end(), val) - lists[pos].begin();
		return lists[pos][idx] == val;
	}
};
```

### 线段树版本（原版）

```cpp
template <class T>
struct sorted_vector {
private:
	static constexpr int DEFAULT_LOAD_FACTOR = 340;
	int len, load, offset;
	std::vector<std::vector<T>> lists;
	std::vector<T> maxes, index;

	void expand(int pos) {
		if ((int) lists[pos].size() > (load << 1)) {
			std::vector<T> half(lists[pos].begin() + load, lists[pos].end());
			lists[pos].erase(lists[pos].begin() + load, lists[pos].end());
			maxes[pos] = lists[pos].back();
			lists.insert(lists.begin() + pos + 1, half);
			maxes.insert(maxes.begin() + pos + 1, half.back());
			index.clear();
		} else if (!index.empty()) {
			for (int i = offset + pos; i; i = (i - 1) >> 1) index[i]++;
			index[0]++;
		}
	}

	std::vector<int> parent(const std::vector<int>& a) {
		int n = a.size();
		std::vector<int> res(n >> 1);
		for (int i = 0; i < (n >> 1); i++) res[i] = a[i << 1] + a[i << 1 | 1];
		return res;
	}
	void build_index() {
		std::vector<int> row0;
		for (const auto& v : lists) row0.emplace_back(v.size());
		if (row0.size() == 1) return index = row0, offset = 0, void();
		std::vector<int> row1 = parent(row0);
		if (row0.size() & 1) row1.emplace_back(row0.back());
		if (row1.size() == 1) {
			index.emplace_back(row1[0]);
			for (int i : row0) index.emplace_back(i);
			return offset = 1, void();
		}
		int dep = 1 << (std::__lg(row1.size() - 1) + 1), u = row1.size();
		for (int i = 1; i <= dep - u; i++) row1.emplace_back(0);
		std::vector<std::vector<int>> tree = {row0, row1};
		while (tree.back().size() > 1) tree.emplace_back(parent(tree.back()));
		for (int i = tree.size() - 1; i >= 0; i--) index.insert(index.end(), tree[i].begin(), tree[i].end());
		offset = (dep << 1) - 1;
	}

	std::pair<int, int> pos(int idx) {
		if (idx < (int) lists[0].size()) return std::make_pair(0, idx);
		if (index.empty()) build_index();
		int p = 0, n = index.size();
		for (int i = 1; i < n; i = p << 1 | 1) {
			if (idx < index[i]) p = i;
			else idx -= index[i], p = i + 1;
		} return std::make_pair(p - offset, idx);
	}

	int loc(int pos, int idx) {
		if (pos == 0) return idx;
		if (index.empty()) build_index();
		int tot = 0;
		for (pos += offset; pos; pos = (pos - 1) >> 1) {
			if (!(pos & 1)) tot += index[pos - 1];
		} return tot + idx;
	}
public:
	sorted_vector() : len(0), load(DEFAULT_LOAD_FACTOR), offset(0) {}
	int size() const {return len;}
	bool empty() const {return maxes.empty();}

	void clear() {
		len = 0, offset = 0;
		lists.clear(), maxes.clear(), index.clear();
	}

	void add(const T& val) {
		if (!maxes.empty()) {
			int pos = std::upper_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
			if (pos == (int) maxes.size()) pos--, lists[pos].emplace_back(val), maxes[pos] = val;
			else lists[pos].insert(std::upper_bound(lists[pos].begin(), lists[pos].end(), val), val);
			expand(pos);
		} else {
			lists.emplace_back(1, val), maxes.emplace_back(val);
		} len++;
	}
  template <class It> void extend(const It& bg, const It& ed) {
		if ((ed - bg) * 4 < len) {
			for (It it = bg; it != ed; it++) add(*it);
			return;
		}
		vector<T> a(bg, ed);
		for (const auto& vec : lists) a.insert(a.end(), vec.begin(), vec.end());
		std::sort(a.begin(), a.end());
		clear(), len = a.size();
		for (int pos = 0; pos < len; pos += load) {
			std::vector<T> vec(a.begin() + pos, a.begin() + std::min(len, pos + load));
			lists.emplace_back(vec), maxes.emplace_back(vec.back());
		}
	}

	bool erase(const T& val) {
		if (maxes.empty()) return false;
		int pos = std::lower_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (pos == (int) maxes.size()) return false;
		int idx = std::lower_bound(lists[pos].begin(), lists[pos].end(), val) - lists[pos].begin();
		if (lists[pos][idx] != val) return false;

		lists[pos].erase(lists[pos].begin() + idx), len--;
		int n = lists[pos].size();
		if (n > (load >> 1)) {
			maxes[pos] = lists[pos].back();
			if (!index.empty()) {
				for (int i = offset + pos; i; i = (i - 1) >> 1) index[i]--;
				index[0]--;
			}
		} else if (lists.size() > 1) {
			if (!pos) pos++;
			int pre = pos - 1;
			lists[pre].insert(lists[pre].end(), lists[pos].begin(), lists[pos].end());
			maxes[pre] = lists[pre].back();
			lists.erase(lists.begin() + pos), maxes.erase(maxes.begin() + pos);
			index.clear(), expand(pre);
		} else if (n > 0) {
			maxes[pos] = lists[pos].back();
		} else {
			lists.erase(lists.begin() + pos), maxes.erase(maxes.begin() + pos);
			index.clear();
		} return true;
	}

	T operator[] (int idx) {
		auto pir = pos(idx);
		return lists[pir.first][pir.second];
	}

	int lower_bound(const T& val) {
		if (maxes.empty()) return 0;
		int pos = std::lower_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (pos == (int) maxes.size()) return len;
		return loc(pos, std::lower_bound(lists[pos].begin(), lists[pos].end(), val) - lists[pos].begin());
	}
	int upper_bound(const T& val) {
		if (maxes.empty()) return 0;
		int pos = std::upper_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (pos == (int) maxes.size()) return len;
		return loc(pos, std::upper_bound(lists[pos].begin(), lists[pos].end(), val) - lists[pos].begin());
	}
	int count(const T& val) {
		if (maxes.empty()) return 0;
		int l = std::lower_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (l == (int) maxes.size()) return 0;
		int r = std::upper_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		int x = std::lower_bound(lists[l].begin(), lists[l].end(), val) - lists[l].begin();
		if (r == (int) maxes.size()) return len - loc(l, x);
		int y = std::upper_bound(lists[r].begin(), lists[r].end(), val) - lists[r].begin();
		if (l == r) return y - x;
		return loc(r, y) - loc(l, x);
	}
	bool contains(const T& val) {
		if (maxes.empty()) return false;
		int pos = std::lower_bound(maxes.begin(), maxes.end(), val) - maxes.begin();
		if (pos == (int) maxes.size()) return false;
		int idx = std::lower_bound(lists[pos].begin(), lists[pos].end(), val) - lists[pos].begin();
		return lists[pos][idx] == val;
	}
};
```

说说这板子怎么用。

- `DEFAULT_LOAD_FACTOR` 是默认块长，实际使用时可以根据需要调整。
- `size(), empty(), clear()`：和 STL 容器一样。
- `add(const T& x)`：插入一个元素 `x`。
- `extend(begin, end)`：插入一段 `[begin, end)` 中的元素。比一个一个 `add` 快。
- `erase(const T& x)`：删除**一个**元素 `x`。若删除成功返回 `true`。若没有找到也不会报错，返回 `false`。
- `operator [](int idx)`：查找排名为 `idx` 的数。排名从 $0$ 开始。若 `idx` 为负或者超过当前长度，行为未定义。
- `lower_bound(const T& val) / upper_bound(const T& val)`：返回 `val` 的前驱 / 后继的**排名**。若没有，返回当前长度。
- `count(const T& val) / contains(const T& val)`：查找 `val` 的出现次数 / 查找 `val` 是否出现。
