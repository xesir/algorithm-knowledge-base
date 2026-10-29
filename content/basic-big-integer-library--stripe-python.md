---
id: basic-big-integer-library
title: 'BigInteger 3.0 大整数库'
category: '基础算法'
subcategory: '高精度'
tags: ["大整数","高精度","BigInteger","库"]
timeComplexity: '见原文'
spaceComplexity: '见原文'
level: B
noCode: true
legacy: true
verified: 2026-10-25
source: 'stripe-python'
---

> 本文由 stripe-python 授权合并，保留原文结构与表述。
## 更新

在一年前，我编写了 [BigInteger2 项目](https://www.luogu.com.cn/article/p6un33cl)。BigInteger3.0 对 BigInteger2 进行了重构，主要更新是将动态分配空间改为 std::vector 自动分配空间，并将实现精细化。

由于之后的更新不希望文章重新审核，因此可到 [剪贴板](https://www.luogu.com.cn/paste/cm3zdwy5) 查看。

```cpp
/*
  BigInteger.h (Version 3.0)
  stripe-python https://www.luogu.com.cn/user/928879
 */

#ifndef BIGINTEGER_H
#define BIGINTEGER_H
#define BIGINTERGER_VERSION (3.0)

#include <algorithm>
#include <cmath>
#include <climits>
#include <chrono>
#include <cstdint>
#include <functional>
#include <iomanip>
#include <sstream>
#include <random>
#include <vector>
#if __cplusplus >= 202002L
#include <compare>
#endif

class ZeroDivisionError : public std::exception {
public:
	const char* what() const throw() {return "Division is zero";}
};
class FFTLimitExceededError : public std::exception {
public:
	const char* what() const throw() {return "FFT limit exceeded";}
};
class NegativeRadicandError : public std::exception {
public:
	const char* what() const throw() {return "Radicand is negative";}
};

// The constants
using digit_t = int64_t;
constexpr int WIDTH = 8;
constexpr digit_t BASE = 1e8;
constexpr int FFT_LIMIT = 8;
constexpr int NEWTON_DIV_MIN_LEVEL = 8;
constexpr int NEWTON_DIV_LIMIT = 32;
constexpr int NEWTON_SQRT_LIMIT = 48;
constexpr int NEWTON_SQRT_MIN_LEVEL = 6;
static_assert(NEWTON_DIV_MIN_LEVEL < NEWTON_DIV_LIMIT);
static_assert(NEWTON_SQRT_MIN_LEVEL < NEWTON_SQRT_LIMIT);

struct BigInteger {
protected:
	std::vector<digit_t> digits;
	bool flag;
	BigInteger(const std::vector<digit_t>& v)
	: digits(v.begin(), v.end()), flag(true) {trim();}

	BigInteger& trim() {  // Remove the leading zeros
		while (digits.size() > 1U && digits.back() == 0) digits.pop_back();
		return *this;
	}
	digit_t operator[] (int x) const {return x < (int) digits.size() ? digits[x] : 0;}

	BigInteger& build_binary(const std::vector<bool>&);

	static BigInteger fft_mul(const BigInteger&, const BigInteger&);
	BigInteger newton_inv(int n) const;
	BigInteger sqrt_normal() const;
	BigInteger newton_invsqrt() const;
public:
	BigInteger() : flag(true) {digits.emplace_back(0);}
	BigInteger(const BigInteger& x) {*this = x;}
	BigInteger(const int64_t& x) {*this = x;}
	BigInteger(const std::string& s) {*this = s;}
	BigInteger(const std::vector<bool>& v) {*this = v;}

	BigInteger& operator= (const BigInteger&);
	BigInteger& operator= (const int64_t&);
	BigInteger& operator= (const std::string&);
	BigInteger& operator= (const std::vector<bool>&);

	std::string to_string() const;
	int64_t to_int64() const;
	std::vector<bool> to_binary() const;
#ifdef __SIZEOF_INT128__
	BigInteger& from_int128(const __int128&);
	__int128 to_int128() const;
#endif  // __SIZEOF_INT128__

	// I/O operations
	friend std::ostream& operator<< (std::ostream& out, const BigInteger& x) {
		if (!x.flag) out << '-';
		out << x.digits.back();
		int n = x.digits.size();
		for (int i = n - 2; i >= 0; i--) out << std::setw(WIDTH) << std::setfill('0') << x.digits[i];
		return out;
	}
	friend std::istream& operator>> (std::istream& in, BigInteger& x) {
		std::string s;
		return in >> s, x = s, in;
	}

	bool zero() const {return digits.size() == 1 && digits[0] == 0;}
	bool operator! () const {return digits.size() != 1 || digits[0] != 0;}
	bool positive() const {return flag && !zero();}
	bool negative() const {return !flag;}
	int _digit_len() const {return digits.size();}

	BigInteger _move_l(int) const;
	BigInteger _move_r(int) const;

	int compare(const BigInteger&) const;
	bool operator== (const BigInteger&) const;
#if __cplusplus >= 202002L
	std::strong_ordering operator<=> (const BigInteger&) const;
#else
	bool operator< (const BigInteger&) const;
	bool operator> (const BigInteger&) const;
	bool operator!= (const BigInteger&) const;
	bool operator<= (const BigInteger&) const;
	bool operator>= (const BigInteger&) const;
#endif   // __cplusplus >= 202002L

	BigInteger operator- () const;
	BigInteger operator~ () const;
	BigInteger abs() const;

	BigInteger& operator+= (const BigInteger&);
	BigInteger operator+ (const BigInteger&) const;
	BigInteger& operator++ ();
	BigInteger operator++ (int);

	BigInteger& operator-= (const BigInteger&);
	BigInteger operator- (const BigInteger&) const;
	BigInteger& operator-- ();
	BigInteger operator-- (int);

	BigInteger& operator*= (const BigInteger&);
	BigInteger operator* (const BigInteger&) const;
	BigInteger square() const;
	BigInteger& operator*= (int32_t);
	BigInteger operator* (const int32_t&) const;

	BigInteger half() const;
	BigInteger& operator/= (int64_t);
	BigInteger operator/ (const int64_t&) const;
	std::pair<BigInteger, BigInteger> divmod(const BigInteger&) const;
	BigInteger operator/ (const BigInteger&) const;
	BigInteger& operator/= (const BigInteger&);
	BigInteger operator% (const BigInteger&) const;
	BigInteger& operator%= (const BigInteger&);
	bool mod2() const {return digits[0] & 1;}

	BigInteger pow(int64_t) const;
	BigInteger pow(int64_t, const BigInteger&) const;

	BigInteger sqrt() const;
	BigInteger root(const int64_t&) const;

	BigInteger gcd(BigInteger) const;
	BigInteger lcm(const BigInteger&) const;

	BigInteger operator<< (const int64_t&) const;
	BigInteger operator>> (const int64_t&) const;
	BigInteger& operator<<= (const int64_t&);
	BigInteger& operator>>= (const int64_t&);

	BigInteger operator& (const BigInteger&) const;
	BigInteger operator| (const BigInteger&) const;
	BigInteger operator^ (const BigInteger&) const;
	BigInteger& operator&= (const BigInteger&);
	BigInteger& operator|= (const BigInteger&);
	BigInteger& operator^= (const BigInteger&);
};

BigInteger& BigInteger::operator= (const BigInteger& x) {
	flag = x.flag, digits = std::vector<digit_t>(x.digits.begin(), x.digits.end());
	return *this;
}
BigInteger& BigInteger::operator= (const int64_t& x) {
	if (x == LLONG_MIN) return *this = "-9223372036854775808";
	digits.clear(), flag = (x >= 0), digits.reserve(4);
	if (x == 0) return digits.emplace_back(0), *this;
	int64_t n = std::abs(x);
	do {digits.emplace_back(n % BASE), n /= BASE;} while (n);
	return *this;
}
BigInteger& BigInteger::operator= (const std::string& s) {
	digits.clear(), flag = true, digits.reserve(s.size() / WIDTH + 1);
	if (s.empty() || s == "-") return *this = 0;
	int n = s.size(), i = 0;
	while (i < n && s[i] == '-') flag ^= 1, i++;
	for (int j = s.size() - 1; j >= i; j -= WIDTH) {
		int start = std::max(i, j - WIDTH + 1), len = j - start + 1;
		digits.emplace_back(std::stoll(s.substr(start, len)));
	}
	return trim();
}
BigInteger& BigInteger::build_binary(const std::vector<bool>& v) {
	BigInteger k = 1;
	for (int i = v.size() - 1; i >= 0; i--, k += k) {
		if (v[i]) *this += k;
	}
	return *this;
}
BigInteger& BigInteger::operator= (const std::vector<bool>& v) {
	*this = 0;
	if (v.empty()) return *this;
	if (!v[0]) return build_binary(v);
	int n = v.size();
	std::vector<bool> b(n);
	for (int i = 0; i < n; i++) b[i] = v[i] ^ 1;
	build_binary(b);
	return *this = ~(*this);
}

std::string BigInteger::to_string() const {  // Convert to std::string
	std::stringstream stream;
	return stream << *this, stream.str();
}
int64_t BigInteger::to_int64() const {   // Convert to int64_t
	int64_t res = 0;
	for (int i = digits.size() - 1; i >= 0; i--) res = res * BASE + digits[i];
	return res;
}
std::vector<bool> BigInteger::to_binary() const {
	if (zero()) return {0};
	std::vector<bool> res;
	if (flag) {
		for (BigInteger x = *this; !x.zero(); x = x.half()) res.emplace_back(x.mod2());
		res.emplace_back(0);
	} else {
		for (BigInteger x = ~(*this); !x.zero(); x = x.half()) res.emplace_back(x.mod2() ^ 1);
		res.emplace_back(1);
	}
	std::reverse(res.begin(), res.end());
	return res;
}

#ifdef __SIZEOF_INT128__
// Support the operations of __int128
BigInteger& BigInteger::from_int128(const __int128& x) {  // Build from __int128
	digits.clear(), flag = (x >= 0), digits.reserve(8);
	if (x == 0) return digits.emplace_back(0), *this;
	__int128 n = (x < 0 ? -x : x);
	do {digits.emplace_back(n % BASE), n /= BASE;} while (n);
	return *this;
}
__int128 BigInteger::to_int128() const {  // Convert to __int128
	__int128 res = 0;
	for (int i = digits.size() - 1; i >= 0; i--) res = res * BASE + digits[i];
	return res;
}
#endif  // __SIZEOF_INT128__

BigInteger BigInteger::_move_l(int x) const {
	std::vector<digit_t> res(x, 0);
	for (const digit_t& i : digits) res.emplace_back(i);
	return res;
}
BigInteger BigInteger::_move_r(int x) const {
	return std::vector<digit_t>(digits.begin() + x, digits.end());
}

int BigInteger::compare(const BigInteger& x) const {
	if (flag && !x.flag) return 1;
	if (!flag && x.flag) return -1;
	int sgn = (flag && x.flag ? 1 : -1);
	int n = digits.size(), m = x.digits.size();
	if (n > m) return sgn;
	if (n < m) return -sgn;
	for (int i = n - 1; i >= 0; i--) {
		if (digits[i] > x.digits[i]) return sgn;
		if (digits[i] < x.digits[i]) return -sgn;
	} return 0;
}
bool BigInteger::operator== (const BigInteger& x) const {return compare(x) == 0;}
#if __cplusplus >= 202002L
std::strong_ordering BigInteger::operator<=> (const BigInteger& x) const {
	int type = compare(x);
	if (type == 0) return std::strong_ordering::equal;
	return type > 0 ? std::strong_ordering::greater : std::strong_ordering::less;
}
#else
bool BigInteger::operator< (const BigInteger& x) const {return compare(x) < 0;}
bool BigInteger::operator> (const BigInteger& x) const {return compare(x) > 0;}
bool BigInteger::operator!= (const BigInteger& x) const {return compare(x) != 0;}
bool BigInteger::operator<= (const BigInteger& x) const {return compare(x) <= 0;}
bool BigInteger::operator>= (const BigInteger& x) const {return compare(x) >= 0;}
#endif   // __cplusplus >= 202002L

BigInteger BigInteger::operator- () const {
	BigInteger res = *this;
	return res.flag ^= 1, res;
}
BigInteger BigInteger::operator~ () const {return -(*this) - 1;}
BigInteger BigInteger::abs() const {
	BigInteger res = *this;
	return res.flag = true, res;
}

BigInteger& BigInteger::operator+= (const BigInteger& x) {
	if (x.negative()) return *this -= x.abs();
	if (this->negative()) return *this = x - this->abs();
	(flag ^= x.flag) ^= 1;
	int n = std::max(digits.size(), x.digits.size()) + 1;
	digit_t carry = 0;
	for (int i = 0; i < n; i++) {
		if (i >= (int) digits.size()) digits.emplace_back(0);
		digits[i] += x[i] + carry;
		if (digits[i] >= BASE) carry = 1, digits[i] -= BASE;
		else carry = 0;
	}
	return trim();
}
BigInteger BigInteger::operator+ (const BigInteger& x) const {
	return BigInteger(*this) += x;
}
BigInteger& BigInteger::operator++ () {return *this += 1;}
BigInteger BigInteger::operator++ (int) {
	BigInteger t = *this;
	return *this += 1, t;
}

BigInteger& BigInteger::operator-= (const BigInteger& x) {
	if (x.negative()) return *this += x.abs();
	if (this->negative()) return *this = -(x + this->abs());
	flag = (*this >= x);
	int n = std::max(digits.size(), x.digits.size());
	digit_t carry = 0;
	for (int i = 0; i < n; i++) {
		if (i >= (int) digits.size()) digits.emplace_back(0);
		digits[i] = flag ? (digits[i] - x[i] - carry) : (x[i] - digits[i] - carry);
		if (digits[i] < 0) digits[i] += BASE, carry = 1;
		else carry = 0;
	} return trim();
}
BigInteger BigInteger::operator- (const BigInteger& x) const {
	return BigInteger(*this) -= x;
}
BigInteger& BigInteger::operator-- () {return *this -= 1;}
BigInteger BigInteger::operator-- (int) {
	BigInteger t = *this;
	return *this -= 1, t;
}

namespace __FFT {  // FFT implementation for faster multiplication
	constexpr long long FFT_BASE = 1e4;
	constexpr double PI2 = 6.283185307179586231995927;
	constexpr double PI6 = 18.84955592153875869598778;
	constexpr int RBASE = 1023;  // The frequency of recalculate the unit roots, must be 2^k-1
	struct complex {
		double real, imag;
		complex(double x = 0.0, double y = 0.0) : real(x), imag(y) {}
		complex operator+ (const complex& other) const {return complex(real + other.real, imag + other.imag);}
		complex operator- (const complex& other) const {return complex(real - other.real, imag - other.imag);}
		complex operator* (const complex& other) const {return complex(real * other.real - imag * other.imag,
			real * other.imag + other.real * imag);}
		complex& operator+= (const complex& other) {return real += other.real, imag += other.imag, *this;}
		complex& operator-= (const complex& other) {return real -= other.real, imag -= other.imag, *this;}
		complex& operator*= (const complex& other) {return *this = *this * other;}
		inline complex conj() const {return complex(imag, -real);}
	};
	template <const int n> inline void fft(complex* a) {
		const int n2 = n >> 1, n4 = n >> 2;
		complex w(1.0, 0.0), w3(1.0, 0.0);
		const complex wn(std::cos(PI2 / n), std::sin(PI2 / n)), wn3(std::cos(PI6 / n), std::sin(PI6 / n));
		for (int i = 0; i < n4; i++, w *= wn, w3 *= wn3) {
			if (!(i & RBASE)) w = complex(std::cos(PI2 * i / n), std::sin(PI2 * i / n)), w3 = w * w * w;
			complex x = a[i] - a[i + n2], y = a[i + n4] - a[i + n2 + n4];
			y = y.conj(), a[i] += a[i + n2], a[i + n4] += a[i + n2 + n4];
			a[i + n2] = (x - y) * w, a[i + n2 + n4] = (x + y) * w3;
		} fft<n2>(a), fft<n4>(a + n2), fft<n4>(a + n2 + n4);
	}
	template <> inline void fft<0>(complex*) {}
	template <> inline void fft<1>(complex*) {}
	template <> inline void fft<2>(complex* a) {complex x = a[0], y = a[1]; a[0] += y, a[1] = x - y;}
	template <> inline void fft<4>(complex* a) {
		complex a0 = a[0], a1 = a[1], a2 = a[2], a3 = a[3], x = a0 - a2, y = a1 - a3;
		y = y.conj(), a[0] += a2, a[1] += a3, a[2] = x - y, a[3] = x + y;
		fft<2>(a);
	}
	template <const int n> inline void ifft(complex* a) {
		const int n2 = n >> 1, n4 = n >> 2;
		ifft<n2>(a), ifft<n4>(a + n2), ifft<n4>(a + n2 + n4);
		complex w(1.0, 0.0), w3(1.0, 0.0);
		const complex wn(std::cos(PI2 / n), -std::sin(PI2 / n)), wn3(std::cos(PI6 / n), -std::sin(PI6 / n));
		for (int i = 0; i < n4; i++, w *= wn, w3 *= wn3) {
			if (!(i & RBASE)) w = complex(std::cos(PI2 * i / n), -std::sin(PI2 * i / n)), w3 = w * w * w;
			complex p = w * a[i + n2], q = w3 * a[i + n2 + n4];
			complex x = a[i], y = p + q, x1 = a[i + n4], y1 = p - q;
			y1 = y1.conj(), a[i] += y, a[i + n4] += y1, a[i + n2] = x - y, a[i + n2 + n4] = x1 - y1;
		}
	}
	template <> inline void ifft<0>(complex*) {}
	template <> inline void ifft<1>(complex*) {}
	template <> inline void ifft<2>(complex* a) {complex x = a[0], y = a[1]; a[0] += y, a[1] = x - y;}
	template <> inline void ifft<4>(complex* a) {
		ifft<2>(a);
		complex p = a[2], q = a[3], x = a[0], y = p + q, x1 = a[1], y1 = p - q;
		y1 = y1.conj(), a[0] += y, a[1] += y1, a[2] = x - y, a[3] = x1 - y1;
	}
	inline void dft(complex* a, int n) {
		if (n <= 1) return;
		switch (n) {
			case 1<<2:fft<1<<2>(a);break;
			case 1<<3:fft<1<<3>(a);break;
			case 1<<4:fft<1<<4>(a);break;
			case 1<<5:fft<1<<5>(a);break;
			case 1<<6:fft<1<<6>(a);break;
			case 1<<7:fft<1<<7>(a);break;
			case 1<<8:fft<1<<8>(a);break;
			case 1<<9:fft<1<<9>(a);break;
			case 1<<10:fft<1<<10>(a);break;
			case 1<<11:fft<1<<11>(a);break;
			case 1<<12:fft<1<<12>(a);break;
			case 1<<13:fft<1<<13>(a);break;
			case 1<<14:fft<1<<14>(a);break;
			case 1<<15:fft<1<<15>(a);break;
			case 1<<16:fft<1<<16>(a);break;
			case 1<<17:fft<1<<17>(a);break;
			case 1<<18:fft<1<<18>(a);break;
			case 1<<19:fft<1<<19>(a);break;
			case 1<<20:fft<1<<20>(a);break;
			case 1<<21:fft<1<<21>(a);break;
			throw FFTLimitExceededError();
		}
	}
	inline void idft(complex* a, int n) {
		if (n <= 1) return;
		switch (n) {
			case 1<<2:ifft<1<<2>(a);break;
			case 1<<3:ifft<1<<3>(a);break;
			case 1<<4:ifft<1<<4>(a);break;
			case 1<<5:ifft<1<<5>(a);break;
			case 1<<6:ifft<1<<6>(a);break;
			case 1<<7:ifft<1<<7>(a);break;
			case 1<<8:ifft<1<<8>(a);break;
			case 1<<9:ifft<1<<9>(a);break;
			case 1<<10:ifft<1<<10>(a);break;
			case 1<<11:ifft<1<<11>(a);break;
			case 1<<12:ifft<1<<12>(a);break;
			case 1<<13:ifft<1<<13>(a);break;
			case 1<<14:ifft<1<<14>(a);break;
			case 1<<15:ifft<1<<15>(a);break;
			case 1<<16:ifft<1<<16>(a);break;
			case 1<<17:ifft<1<<17>(a);break;
			case 1<<18:ifft<1<<18>(a);break;
			case 1<<19:ifft<1<<19>(a);break;
			case 1<<20:ifft<1<<20>(a);break;
			case 1<<21:ifft<1<<21>(a);break;
			throw FFTLimitExceededError();
		}
	}
}

BigInteger BigInteger::fft_mul(const BigInteger& a, const BigInteger& b) {
	int n = a.digits.size(), m = b.digits.size();
	int least = (n + m) << 1, lim = 1;
	while (lim < least) lim <<= 1;

	__FFT::complex* arr = new __FFT::complex[lim];
	for (int i = 0; i < n; i++) {
		arr[i << 1].real = a.digits[i] % 10000LL;
		arr[i << 1 | 1].real = a.digits[i] / 10000LL % 10000LL;
	}
	for (int i = 0; i < m; i++) {
		arr[i << 1].imag = b.digits[i] % 10000LL;
		arr[i << 1 | 1].imag = b.digits[i] / 10000LL % 10000LL;
	}
	__FFT::dft(arr, lim);
	for (int i = 0; i < lim; i++) arr[i] *= arr[i];
	__FFT::idft(arr, lim);

	std::vector<digit_t> res(n + m + 1);
	digit_t carry = 0;
	double inv = 0.5 / lim;
	for (int i = 0; i <= n + m; i++) {
		carry += digit_t(arr[i << 1].imag * inv + 0.5);
		carry += digit_t(arr[i << 1 | 1].imag * inv + 0.5) * 10000LL;
		res[i] += carry % BASE, carry /= BASE;
	}
	delete[] arr;
	return res;
}

BigInteger BigInteger::operator* (const BigInteger& x) const {
	if (zero() || x.zero()) return BigInteger();
	int n = digits.size(), m = x.digits.size();
	if (1LL * n * m >= FFT_LIMIT) {
		BigInteger res = fft_mul(*this, x);
		return res.flag = !(flag ^ x.flag), res;
	}  // When n * m < FFT_LIMIT, using normal multiplication
	std::vector<digit_t> res(n + m + 1);
	for (int i = 0; i < n; i++) {
		for (int j = 0; j < m; j++) {
			res[i + j] += digits[i] * x.digits[j];
			res[i + j + 1] += res[i + j] / BASE, res[i + j] %= BASE;
		}
	}
	BigInteger u(res);
	return u.flag = !(flag ^ x.flag), u;
}
BigInteger& BigInteger::operator*= (const BigInteger& x) {
	return *this = *this * x;
}
BigInteger BigInteger::square() const {  // Calculate the square, faster than a * a
	if (zero()) return BigInteger();
	int n = digits.size();
	if (1LL * n * n < FFT_LIMIT) {  // When n * n < FFT_LIMIT, using normal multiplication
		std::vector<digit_t> res((n << 1) + 1);
		for (int i = 0; i < n; i++) {
			for (int j = 0; j < n; j++) {
				res[i + j] += digits[i] * digits[j];
				res[i + j + 1] += res[i + j] / BASE, res[i + j] %= BASE;
			}
		}
		return res;
	}
	int least = n << 2, lim = 1;
	while (lim < least) lim <<= 1;

	__FFT::complex* arr = new __FFT::complex[lim];
	for (int i = 0; i < n; i++) {
		arr[i << 1].real = arr[i << 1].imag = digits[i] % 10000LL;
		arr[i << 1 | 1].real = arr[i << 1 | 1].imag = digits[i] / 10000LL % 10000LL;
	}
	__FFT::dft(arr, lim);
	for (int i = 0; i < lim; i++) arr[i] *= arr[i];
	__FFT::idft(arr, lim);

	std::vector<digit_t> res((n << 1) + 1);
	digit_t carry = 0;
	double inv = 0.5 / lim;
	for (int i = 0; i <= (n << 1); i++) {
		carry += digit_t(arr[i << 1].imag * inv + 0.5);
		carry += digit_t(arr[i << 1 | 1].imag * inv + 0.5) * 10000LL;
		res[i] += carry % BASE, carry /= BASE;
	}
	delete[] arr;
	return res;
}

BigInteger& BigInteger::operator*= (int32_t x) {
	if (x == 0 || zero()) return *this = 0;
	if (x < 0) flag ^= 1, x = -x;
	digit_t carry = 0;
	for (int i = 0; i < (int) digits.size() || carry != 0; i++) {
		if (i >= (int) digits.size()) digits.emplace_back(0);
		digits[i] = digits[i] * x + carry;
		carry = digits[i] / BASE, digits[i] %= BASE;
	}
	return trim();
}
BigInteger BigInteger::operator* (const int32_t& x) const {
	return BigInteger(*this) *= x;
}

BigInteger BigInteger::half() const {
	BigInteger res = *this;
	for (int i = digits.size() - 1; i >= 0; i--) {
		if ((res[i] & 1) && i > 0) res.digits[i - 1] += BASE;
		res.digits[i] >>= 1;
	}
	return res.trim();
}
BigInteger& BigInteger::operator/= (int64_t x) {
	if (x == 0) throw ZeroDivisionError();
	if (zero()) return *this;
	if (x < 0) flag ^= 1, x = -x;
	digit_t cur = 0;
	for (int i = digits.size() - 1; i >= 0; i--) {
		cur = cur * BASE + digits[i];
		digits[i] = flag ? (cur / x) : (-cur / -x);
		cur %= x;
	}
	return trim();
}
BigInteger BigInteger::operator/ (const int64_t& x) const {
	return BigInteger(*this) /= x;
}

BigInteger BigInteger::newton_inv(int n) const {  // Solve BASE^n / x
	if (zero()) throw ZeroDivisionError();
	int sz = digits.size();
	if (std::min(sz, n - sz) <= NEWTON_DIV_MIN_LEVEL) {
		std::vector<digit_t> a(n + 1);
		a[n] = 1;
		return BigInteger(a).divmod(*this).first;
	}
	int k = (n - sz + 2) >> 1, k2 = k > sz ? 0 : sz - k;
	BigInteger x = _move_r(k2);
	int n2 = k + x.digits.size();
	BigInteger y = x.newton_inv(n2), a = y + y, b = (*this) * y * y;
	return a._move_l(n - n2 - k2) - b._move_r(2 * (n2 + k2) - n) - 1;
}
std::pair<BigInteger, BigInteger> BigInteger::divmod(const BigInteger& x) const {
	BigInteger a = abs(), b = x.abs();
	if (b == 0) throw ZeroDivisionError();
	if (a < b) return std::make_pair(0, flag ? a : -a);
	int n = a.digits.size(), m = b.digits.size();

	if (std::min(n, n - m) > NEWTON_DIV_LIMIT) {
		int k = n - m + 2, k2 = std::max(0, m - k);
		BigInteger b2 = b._move_r(k2);
		if (k2 != 0) b2 += 1;
		int n2 = k + b2.digits.size();
		BigInteger u = a * b2.newton_inv(n2), q = u._move_r(n2 + k2), r = (*this) - q * b;
		while (r >= b) q += 1, r -= b;
		q.flag = !(flag ^ x.flag), r.flag = flag;
		return std::make_pair(q, r);
	}

	int32_t t = BASE / (x.digits.back() + 1);
	a *= t, b *= t, n = a.digits.size(), m = b.digits.size();
	BigInteger q = 0, r = 0;
	q.digits.resize(n);
	for (int i = n - 1; i >= 0; i--) {
		r = r * BASE + a.digits[i];
		digit_t d1 = r[m], d2 = r[m - 1], d = (d1 * BASE + d2) / b.digits.back();
		r -= b * d;
		while (r.negative()) r += b, d--;
		q.digits[i] = d;
	}
	q.trim(), q.flag = !(flag ^ x.flag), r.flag = flag;
	return std::make_pair(q, r / t);
}

BigInteger BigInteger::operator/ (const BigInteger& x) const {
	return divmod(x).first;
}
BigInteger& BigInteger::operator/= (const BigInteger& x) {
	return *this = divmod(x).first;
}
BigInteger BigInteger::operator% (const BigInteger& x) const {
	return divmod(x).second;
}
BigInteger& BigInteger::operator%= (const BigInteger& x) {
	return *this = divmod(x).second;
}

BigInteger BigInteger::pow(int64_t b) const {
	BigInteger a = *this, res = 1;
	for (; b; b >>= 1) {
		if (b & 1) res *= a;
		a = a.square();
	} return res;
}
BigInteger BigInteger::pow(int64_t b, const BigInteger& p) const {
	BigInteger a = *this % p, res = 1;
	for (; b; b >>= 1) {
		if (b & 1) res = res * a % p;
		a = a.square() % p;
	} return res;
}

BigInteger BigInteger::sqrt_normal() const {
	BigInteger x0 = BigInteger(BASE)._move_l((digits.size() + 2) >> 1);
	BigInteger x = (x0 + *this / x0).half();
	while (x < x0) std::swap(x, x0), x = (x0 + *this / x0).half();
	return x0;
}
BigInteger BigInteger::newton_invsqrt() const {	  // Solve BASE^2k / sqrt(x)
	int n = digits.size(), n2 = n + (n & 1), k2 = (n2 + 2) / 4 * 2;
	if (n <= NEWTON_SQRT_MIN_LEVEL) return BigInteger(1)._move_l(n2 << 1) / this->_move_l(n2 << 1).sqrt_normal();

	BigInteger x2k(std::vector<digit_t>(digits.begin() + n2 - k2, digits.end()));
	BigInteger s = x2k.newton_invsqrt()._move_l((n2 - k2) / 2);
	BigInteger x2 = (s + s + s).half() - (s * s * s * *this).half()._move_r(n2 << 1);
	BigInteger rx = BigInteger(1)._move_l(n2 << 1) - *this * x2.square(), delta = 1;

	if (rx.negative()) {
		for (; rx.negative(); delta += delta) {
			BigInteger t = (x2 + x2 - delta + delta.square()) * (*this);
			x2 -= delta, rx += t;
		}
	} else {
		while (true) {
			BigInteger t = (x2 + x2 + delta) * delta * (*this);
			if (t > rx) break;
			x2 += delta, rx -= t, delta += delta;
		}
	}
	for (; delta.positive(); delta = delta.half()) {
		BigInteger t = (x2 + x2 + delta) * delta * (*this);
		if (t <= rx) x2 += delta, rx -= t;
	}
	return x2;
}
BigInteger BigInteger::sqrt() const {
	if (negative()) throw NegativeRadicandError();
	if (digits.size() <= NEWTON_SQRT_LIMIT) return sqrt_normal();
	int n = digits.size(), n2 = (n & 1) ? n + 1 : n;
	BigInteger res = (*this * newton_invsqrt())._move_r(n2), r = *this - res.square(), delta = 1;
	while (true) {
		BigInteger dr = (res + res + delta) * delta;
		if (dr > r) break;
		r -= dr, res += delta, delta += delta;
	}
	for (; delta > 0; delta = delta.half()) {
		BigInteger dr = (res + res + delta) * delta;
		if (dr <= r) r -= dr, res += delta;
	}
	return res;
}

BigInteger BigInteger::root(const int64_t& m) const {
	if (m <= 0 || (m % 2 == 0 && negative())) throw NegativeRadicandError();
	if (m == 1 || zero()) return *this;
	if (m == 2) return sqrt();
	int n = digits.size();
	if (n <= m) {
		digit_t l = 0, r = BASE - 1;
		while (l < r) {
			digit_t mid = (l + r + 1) >> 1;
			if (BigInteger(mid).pow(m) <= *this) l = mid;
			else r = mid - 1;
		}
		return l;
	}
	if (n <= m * 2) {
		BigInteger res;
		res.digits.resize(2, 0);
		digit_t l = 0, r = BASE - 1;
		while (l < r) {
			digit_t mid = (l + r + 1) >> 1;
			res.digits[1] = mid;
			if (res.pow(m) <= *this) l = mid;
			else r = mid - 1;
		}
		res.digits[1] = l, l = 0, r = BASE - 1;
		while (l < r) {
			digit_t mid = (l + r + 1) >> 1;
			res.digits[0] = mid;
			if (res.pow(m) <= *this) l = mid;
			else r = mid - 1;
		}
		res.digits[0] = l;
		return res.trim();
	}
	int t = n / m / 2;
	BigInteger s = (_move_r(t * m).root(m) + 1)._move_l(t);
	BigInteger res = (s * (m - 1) + *this / s.pow(m - 1)) / m;
	digit_t l = std::max<digit_t>(res.digits[0] - 100, 0), r = std::min(res.digits[0] + 100, BASE - 1);
	while (l < r) {
		digit_t mid = (l + r + 1) >> 1;
		res.digits[0] = mid;
		if (res.pow(m) <= *this) l = mid;
		else r = mid - 1;
	}
	return res.digits[0] = l, res.trim();
}

BigInteger BigInteger::gcd(BigInteger b) const {
	BigInteger a = *this;
	if (a < b) std::swap(a, b);
	if (b == 0) return a;
	int64_t t = 0;
	while (!a.mod2() && !b.mod2()) a = a.half(), b = b.half(), t++;
	while (b.positive()) {
		if (!a.mod2()) a = a.half();
		else if (!b.mod2()) b = b.half();
		else a -= b;
		if (a < b) std::swap(a, b);
	}
	return a * BigInteger(2).pow(t);
}
BigInteger BigInteger::lcm(const BigInteger& x) const {
	return *this / gcd(x) * x;
}

BigInteger BigInteger::operator<< (const int64_t& x) const {return *this * BigInteger(2).pow(x);}
BigInteger BigInteger::operator>> (const int64_t& x) const {return *this / BigInteger(2).pow(x);}
BigInteger& BigInteger::operator<<= (const int64_t& x) {return *this *= BigInteger(2).pow(x);}
BigInteger& BigInteger::operator>>= (const int64_t& x) {return *this /= BigInteger(2).pow(x);}

BigInteger __helper(const BigInteger& x, const BigInteger& y, const std::function<bool(bool, bool)>& op) {
	std::vector<bool> a = x.to_binary(), b = y.to_binary();
	int n = a.size(), m = b.size(), lim = std::max(n, m);
	std::vector<bool> res(lim);
	for (int i = 0; i < lim; ++i) res[i] = op(i < n ? a[i] : 0, i < m ? b[i] : 0);
	return res;
}
BigInteger BigInteger::operator& (const BigInteger& x) const {
	return __helper(*this, x, [](bool a, bool b) -> bool {return a & b;});
}
BigInteger BigInteger::operator| (const BigInteger& x) const {
	return __helper(*this, x, [](bool a, bool b) -> bool {return a | b;});
}
BigInteger BigInteger::operator^ (const BigInteger& x) const {
	return __helper(*this, x, [](bool a, bool b) -> bool {return a ^ b;});
}
BigInteger& BigInteger::operator&= (const BigInteger& x) {
	return *this = __helper(*this, x, [](bool a, bool b) -> bool {return a & b;});
}
BigInteger& BigInteger::operator|= (const BigInteger& x) {
	return *this = __helper(*this, x, [](bool a, bool b) -> bool {return a | b;});
}
BigInteger& BigInteger::operator^= (const BigInteger& x) {
	return *this = __helper(*this, x, [](bool a, bool b) -> bool {return a ^ b;});
}

BigInteger factorial(int32_t n) {
	BigInteger res = 1;
	for (int32_t i = 2; i <= n; i++) res *= i;
	return res;
}
BigInteger i_random(int32_t n) {
	std::mt19937 e(std::chrono::system_clock::now().time_since_epoch().count());
	std::uniform_int_distribution<unsigned> u0(0, 9), u1(1, 9);
	std::string s;
	s += u0(e) ^ 48;
	for (int32_t i = 2; i <= n; i++) s += u1(e) ^ 48;
	return s;
}

BigInteger i_gcd(const BigInteger& a, const BigInteger& b) {return a.gcd(b);}
BigInteger i_lcm(const BigInteger& a, const BigInteger& b) {return a.lcm(b);}
BigInteger i_sqrt(const BigInteger& a) {return a.sqrt();}
BigInteger i_root(const BigInteger& a, int64_t x) {return a.root(x);}
BigInteger i_pow(const BigInteger& a, int64_t b) {return a.pow(b);}
BigInteger i_pow(const BigInteger& a, int64_t b, const BigInteger& p) {return a.pow(b, p);}
#endif  // BIGINTEGER_H
```

## 操作文档

BigInteger 3.0 版本支持多种操作。下面的复杂度分析中，$w=8, w'=4$。

## 初始化

- `BigInteger()`：创建一个新的 `BigInteger`，默认值为 $0$。
- `BigInteger(const BigInteger& x)`：创建一个新的 `BigInteger`，值为 $x$，时间复杂度 $O(\dfrac{n}{w})$，其中 $n$ 为 $x$ 的长度。
- `BigInteger(int64_t x)`：创建一个新的 `BigInteger`，值为 $x$，时间复杂度 $O(\log x)$。
- `BigInteger(const std::string& s)`：从字符串创建一个新的 `BigInteger`，时间复杂度 $O(n)$，其中 $n$ 为字符串长度。合法的字符串必须由若干个 `-` 号后接若干数字字符组成。
- `BigInteger(const std::vector<bool>& v)`：从二进制表示创建一个新的 `BigInteger`，时间复杂度 $O(n^2)$，其中 $n$ 为二进制表示长度。
- `BigInteger.from_int128(__int128 x)`：`static` 型函数，从 `__int128` 类型创建一个新的 `BigInteger`，值为 $x$，时间复杂度 $O(\log x)$。在不支持 `__int128` 的环境中，`BigInteger` 无此操作。

## I / O

- `std::cin >> x`：输入一个 `BigInteger` 的值，时间复杂度 $O(n)$，其中 $n$ 为字符串长度。合法输入与从字符串初始化 `BigInteger` 的要求相同。
- `std::cout << x`：输出一个 `BigInteger` 的值，时间复杂度 $O(n)$，其中 $n$ 为此整数的长度。

## 类型转换

- `a.to_string()`：返回值为 `std::string` 类型，返回 `a` 转换为字符串后的结果。时间复杂度 $O(n)$，其中 $n$ 为此整数的长度。
- `a.to_int64()`：返回值为 `int64_t` 类型，返回 `a` 转换为 64 位整数后的结果，时间复杂度 $O(\dfrac{n}{w})$，其中 $n$ 为此整数的长度。若结果发生溢出，则行为未定义。
- `a.to_binary()`：返回值为 `std::vector<bool>` 类型，返回 $a$ 的二进制表示，时间复杂度 $O(n^2)$，其中 $n$ 为此整数的长度
- `a.to_int128()`：返回值为 `__int128` 类型，返回 `a` 转换为 128 位整数后的结果，时间复杂度 $O(\dfrac{n}{w})$，其中 $n$ 为此整数的长度。若结果发生溢出，则行为未定义。在不支持 `__int128` 的环境中，`BigInteger` 无此操作。

## 基本运算

- `a.zero()`：判断 $a$ 是否为 $0$，时间复杂度 $O(1)$。
- `!a`：判断 $a$ 是否不为 $0$，时间复杂度 $O(1)$。
- `a.positive()`：判断 $a$ 是否为正数，时间复杂度 $O(1)$。**$0$ 不是正数。**
- `a.negative()`：判断 $a$ 是否为负数，时间复杂度 $O(1)$。
- `a.compare(const BigInteger& b)`：返回 $a$ 与 $b$ 比较的结果，返回值为 `int` 类型。若 $a<b$ 返回 $-1$，$a=b$ 返回 $0$，$a>b$ 返回 $1$。时间复杂度 $O(\dfrac{n}{w})$，其中 $n$ 为两整数的长度的较大值。
- `a <=> b, a <= b, a < b, a == b, a != b, a > b, a >= b`：返回 $a$ 与 $b$ 比较的对应结果，时间复杂度 $O(\dfrac{n}{w})$，其中 $n$ 为两整数的长度的较大值。
- `-a`：返回 $-a$，时间复杂度 $O(\dfrac{n}{w})$，其中 $n$ 为此整数的长度。
- `~a`：返回 $-a-1$，时间复杂度 $O(\dfrac{n}{w})$，其中 $n$ 为此整数的长度。
- `a.abs()`：返回 $|a|$，时间复杂度 $O(\dfrac{n}{w})$，其中 $n$ 为此整数的长度。
- `a + b`：返回 $a+b$，时间复杂度 $O(\dfrac{n}{w})$，其中 $n$ 为两整数的长度的较大值。支持 `a += b` 原地加法。
- `a - b`：返回 $a-b$，时间复杂度 $O(\dfrac{n}{w})$，其中 $n$ 为两整数的长度的较大值。支持 `a -= b` 原地减法。
- `a * b`：返回 $a \times b$，时间复杂度 $O(\dfrac{n \log n}{w'})$，其中 $n$ 为两整数的长度的较大值。当 $n <$ `8 * FFT_LIMIT` 时，采用 $O(\dfrac{n^2}{w^2})$ 竖式乘法计算。`FFT_LIMIT` 默认为 $8$。特别地，当 `b` 为 `int32_t` 类型时时间复杂度为 $O(\dfrac{n}{w})$，且支持原地乘法。$n > 2^{20}$ 时抛出 `FFTLimitExceededError` 异常。
- `a.square()`：返回 $a^2$，时间复杂度 $O(\dfrac{n}{w})$，其中 $n$ 为此整数的长度，快于 `a * a`。
- `a.half()`：返回 $\lfloor \dfrac{a}{2} \rfloor$，时间复杂度 $O(\dfrac{n}{w})$，其中 $n$ 为此整数的长度，快于 `a / 2`。
- `a / b`：返回 $\lfloor \dfrac{a}{b} \rfloor$，时间复杂度 $O(\dfrac{n \log n}{w'})$，其中 $n$ 为两整数的长度的较大值。当 $n <$ `8 * NEWTON_DIV_LIMIT` 时，采用 $O(\dfrac{n^2}{w})$ 竖式乘法计算。`NEWTON_DIV_LIMIT` 默认为 $32$。特别地，当 `b` 为 `int64_t` 类型时时间复杂度为 $O(\dfrac{n}{w})$，且支持原地除法。$b=0$ 时抛出 `ZeroDivisionError` 异常。
- `a % b`：返回 $a \bmod b$，时间复杂度与 `a / b` 一致。$b=0$ 时抛出 `ZeroDivisionError` 异常。
- `a.divmod(b)`：返回一个 `std::pair`，分别为 $(\lfloor \dfrac{a}{b} \rfloor, a \bmod b)$，时间复杂度与 `a / b` 一致，但 $b$ 为 `int64_t` 类型时无优化。$b=0$ 时抛出 `ZeroDivisionError` 异常。
- `a.mod2()`：返回 $a \bmod 2$，时间复杂度 $O(1)$。
- `a.pow(b)` 或 `i_pow(a, b)`：返回 $a^b$，时间复杂度 $O(\dfrac{nb \log nb}{w})$，其中 $n$ 为此整数的长度。$b$ 应为 `int64_t` 类型。
- `a.pow(b, p)` 或 `i_pow(a, b, p)`：返回 $a^b \bmod p$，时间复杂度 $O(\dfrac{nb \log nb}{w})$，其中 $n$ 为此整数的长度。$b$ 应为 `int64_t` 类型，$p$ 为 `BigInteger` 类型。
- `a.sqrt()` 或 `i_sqrt(a)`：返回 $\lfloor \sqrt{a} \rfloor$，时间复杂度 $O(\dfrac{n \log n}{w})$，其中 $n$ 为此整数的长度。$a<0$ 时抛出 `NegativeRadicandError` 异常。
- `a.root(x)` 或 `i_root(a, x)`：返回 $\lfloor \sqrt[x]{a} \rfloor$，时间复杂度 $O(\dfrac{n \log n}{w})$，其中 $n$ 为此整数的长度。$x \le 0$ 时抛出 `NegativeRadicandError` 异常。$2 \mid x$ 且 $a < 0$ 时抛出 `NegativeRadicandError` 异常。
- `a.gcd(b) `或 `i_gcd(a, b)`：返回 $\gcd(a,b)$，时间复杂度 $O(\dfrac{n^2}{w})$，其中 $n$ 为两整数的长度的较大值。
- `a.lcm(b)` 或 `i_lcm(a, b)`：返回 $\operatorname{lcm}(a,b)$，时间复杂度 $O(\dfrac{n^2}{w})$，其中 $n$ 为两整数的长度的较大值。
- `a << x`：返回 $a \times 2^x$，时间复杂度 $O(\dfrac{(n+x) \log(n+x)}{w'})$，其中 $n$ 为此整数的长度。
- `a >> x`：返回 $\lfloor \dfrac{a}{2^x} \rfloor$，时间复杂度 $O(\dfrac{(n-x) \log(n-x)}{w'})$，其中 $n$ 为此整数的长度。
- `a & b`：返回 $a,b$ 的按位与，时间复杂度 $O(n^2)$，其中 $n$ 为两整数的长度的较大值。
- `a | b`：返回 $a,b$ 的按位或，时间复杂度 $O(n^2)$，其中 $n$ 为两整数的长度的较大值。
- `a ^ b`：返回 $a,b$ 的按位异或，时间复杂度 $O(n^2)$，其中 $n$ 为两整数的长度的较大值。

## 其他函数

- `factorial(n)`：返回值为 `BigInteger` 类型，返回 $n!$，时间复杂度 $O(\dfrac{n^2}{w})$。
- `i_random(n)`：返回长度为 $n$ 的随机 `BigInteger`，时间复杂度 $O(n)$。

## 内部函数

此部分函数不建议使用。

- `a._digit_len()`：返回 $\lfloor \dfrac{n}{w} \rfloor$，其中 $n$ 为此整数的长度，时间复杂度 $O(1)$。
- `a._move_l(x)`：返回 $|n \times 10^{wx}|$，时间复杂度 $O(\dfrac{n}{w}+x)$，其中 $n$ 为此整数的长度。
- `a._move_r(x)`：返回 $|\lfloor \dfrac{n}{10^{wx}} \rfloor|$，时间复杂度 $O(\dfrac{n}{w}-x)$，其中 $n$ 为此整数的长度。
- `__FFT::dft(a, n)`：将长度为 $n$ 的 `__FFT::complex[]` 类型的 `a` 数组作 DFT 变换，时间复杂度 $O(n\log n)$。要求 $n$ 是不大于 $2^{21}$ 的 $2$ 的幂。
- `__FFT::idft(a, n)`：将长度为 $n$ 的 `__FFT::complex[]` 类型的 `a` 数组作 IDFT 变换，时间复杂度 $O(n\log n)$。要求 $n$ 是不大于 $2^{21}$ 的 $2$ 的幂。
- `__helper(a, b, f)`：将 $a,b$ 按位执行 `f` 运算，时间复杂度 $O(n^2)$，其中 $n$ 为两整数的长度的较大值。`f` 应当为一个形如 `bool f(bool, bool)` 的函数。

## 优缺点

优点：

- 高度封装，几乎支持 `int` 类型所有操作，无需手写。
- 速度快，大部分操作已优化到一个较优秀的复杂度。
- 代码长度较短。

缺点：

- 位运算速度较慢。
- 不支持超大位数整数的乘除法。具体地，位数大于 $2^{20}=1048576$ 时抛出 `FFTLimitExceededError` 异常。
- 偶尔出现的 bug。

## 疑问

Q1: 为什么不支持超大位数整数的乘除法？

A1: 因为 FFT 采用分块计算单位根的方法，提升效率的同时牺牲了稳定性。由于 BigInteger 的设计目的是服务 OI 竞赛，一般不会有超过 $10^6$ 位大整数。若您需要更大位数的整数，可将 `__FFT::RBASE` 改为 $63$，它可以支持 $3 \times 10^7$ 位数的整数。

Q2: 为什么运算符不实现为自由函数？

A2: 如果实现为自由函数，`BigInteger` 内部的 `digits` 需要声明为 `public`，会造成不安全。您可以通过显式类型转换或者将 `BigInteger` 写到运算符左边来避免问题。

Q3: 为什么 `BigInteger`  的操作函数带 `i_` 前缀？

A3: 表明这个函数用于操作 `BigInteger` 类型。未来计划实现 `BigDecimal` 类型，用 `d_` 前缀来标识。

## 感谢

感谢为此项目作出贡献的用户，排名按字典序。

- @[bcdmwSjy](https://www.luogu.com.cn/user/514727)
- @[kkkkkse05](https://www.luogu.com.cn/user/340145)
- @[konyakest](https://www.luogu.com.cn/user/482660)
- @[Noiers](https://www.luogu.com.cn/user/1402616)
- @[Xudongning](https://www.luogu.com.cn/user/1636821)
