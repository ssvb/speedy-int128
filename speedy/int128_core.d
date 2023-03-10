// This is a pretty much unmodified copy of core.int128 from druntime
// Added "core_*" prefixes to functions. Removed the functions, which
// are not really used by the Int128 struct.

/*
 * Not optimized for speed.
 *
 * Copyright: Copyright D Language Foundation 2022.
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Authors:   Walter Bright
 * Source:    $(DRUNTIMESRC core/_int128.d)
 */

module speedy.int128_core;

nothrow:
@safe:
@nogc:

enum Ubits = uint(ulong.sizeof * 8);

struct Cent
{
    version (LittleEndian)
    {
        ulong lo;  // low 64 bits
        ulong hi;  // high 64 bits
    }
    else
    {
        ulong hi;  // high 64 bits
        ulong lo;  // low 64 bits
    }
}

enum Cent One = { lo:1 };
enum Cent Zero = { lo:0 };
enum Cent MinusOne = core_neg(One);

/*****************************
 * Test against 0
 * Params:
 *      c = Cent to test
 * Returns:
 *      true if != 0
 */
pure
bool core_tst(Cent c)
{
    return c.hi || c.lo;
}


/*****************************
 * Complement
 * Params:
 *      c = Cent to complement
 * Returns:
 *      complemented value
 */
pure
Cent core_com(Cent c)
{
    c.lo = ~c.lo;
    c.hi = ~c.hi;
    return c;
}

/*****************************
 * Negate
 * Params:
 *      c = Cent to negate
 * Returns:
 *      negated value
 */
pure
Cent core_neg(Cent c)
{
    if (c.lo == 0)
        c.hi = -c.hi;
    else
    {
        c.lo = -c.lo;
        c.hi = ~c.hi;
    }
    return c;
}

/*****************************
 * Increment
 * Params:
 *      c = Cent to increment
 * Returns:
 *      incremented value
 */
pure
Cent core_inc(Cent c)
{
    return core_add(c, One);
}

/*****************************
 * Decrement
 * Params:
 *      c = Cent to decrement
 * Returns:
 *      incremented value
 */
pure
Cent core_dec(Cent c)
{
    return core_sub(c, One);
}

/*****************************
 * Unsigned shift right one bit
 * Params:
 *      c = Cent to shift
 * Returns:
 *      shifted value
 */
pure
Cent core_shr1(Cent c)
{
    c.lo = (c.lo >> 1) | ((c.hi & 1) << (Ubits - 1));
    c.hi >>= 1;
    return c;
}

/*****************************
 * Shift left n bits
 * Params:
 *      c = Cent to shift
 *      n = number of bits to shift
 * Returns:
 *      shifted value
 */
pure
Cent core_shl(Cent c, uint n)
{
    if (n >= Ubits * 2)
        return Zero;

    if (n >= Ubits)
    {
        c.hi = c.lo << (n - Ubits);
        c.lo = 0;
    }
    else
    {
        c.hi = ((c.hi << n) | (c.lo >> (Ubits - n - 1) >> 1));
        c.lo = c.lo << n;
    }
    return c;
}

/*****************************
 * Unsigned shift right n bits
 * Params:
 *      c = Cent to shift
 *      n = number of bits to shift
 * Returns:
 *      shifted value
 */
pure
Cent core_shr(Cent c, uint n)
{
    if (n >= Ubits * 2)
        return Zero;

    if (n >= Ubits)
    {
        c.lo = c.hi >> (n - Ubits);
        c.hi = 0;
    }
    else
    {
        c.lo = ((c.lo >> n) | (c.hi << (Ubits - n - 1) << 1));
        c.hi = c.hi >> n;
    }
    return c;
}

/*****************************
 * Arithmetic shift right n bits
 * Params:
 *      c = Cent to shift
 *      n = number of bits to shift
 * Returns:
 *      shifted value
 */
pure
Cent core_sar(Cent c, uint n)
{
    const signmask = -(c.hi >> (Ubits - 1));
    const signshift = (Ubits * 2) - n;
    c = core_shr(c, n);

    // Sign extend all bits beyond the precision of Cent.
    if (n >= Ubits * 2)
    {
        c.hi = signmask;
        c.lo = signmask;
    }
    else if (signshift >= Ubits * 2)
    {
    }
    else if (signshift >= Ubits)
    {
        c.hi &= ~(ulong.max << (signshift - Ubits));
        c.hi |= signmask << (signshift - Ubits);
    }
    else
    {
        c.hi = signmask;
        c.lo &= ~(ulong.max << signshift);
        c.lo |= signmask << signshift;
    }
    return c;
}

/****************************
 * And c1 & c2.
 * Params:
 *      c1 = operand 1
 *      c2 = operand 2
 * Returns:
 *      c1 & c2
 */
pure
Cent core_and(Cent c1, Cent c2)
{
    const Cent ret = { lo:c1.lo & c2.lo, hi:c1.hi & c2.hi };
    return ret;
}

/****************************
 * Or c1 | c2.
 * Params:
 *      c1 = operand 1
 *      c2 = operand 2
 * Returns:
 *      c1 | c2
 */
pure
Cent core_or(Cent c1, Cent c2)
{
    const Cent ret = { lo:c1.lo | c2.lo, hi:c1.hi | c2.hi };
    return ret;
}

/****************************
 * Xor c1 ^ c2.
 * Params:
 *      c1 = operand 1
 *      c2 = operand 2
 * Returns:
 *      c1 ^ c2
 */
pure
Cent core_xor(Cent c1, Cent c2)
{
    const Cent ret = { lo:c1.lo ^ c2.lo, hi:c1.hi ^ c2.hi };
    return ret;
}

/****************************
 * Add c1 to c2.
 * Params:
 *      c1 = operand 1
 *      c2 = operand 2
 * Returns:
 *      c1 + c2
 */
pure
Cent core_add(Cent c1, Cent c2)
{
    ulong r = cast(ulong)(c1.lo + c2.lo);
    const Cent ret = { lo:r, hi:cast(ulong)(c1.hi + c2.hi + (r < c1.lo)) };
    return ret;
}

/****************************
 * Subtract c2 from c1.
 * Params:
 *      c1 = operand 1
 *      c2 = operand 2
 * Returns:
 *      c1 - c2
 */
pure
Cent core_sub(Cent c1, Cent c2)
{
    return core_add(c1, core_neg(c2));
}

/****************************
 * Multiply c1 * c2.
 * Params:
 *      c1 = operand 1
 *      c2 = operand 2
 * Returns:
 *      c1 * c2
 */
pure
Cent core_mul(Cent c1, Cent c2)
{
    enum mulmask = (1UL << (Ubits / 2)) - 1;
    enum mulshift = Ubits / 2;

    // This algorithm splits the operands into 4 words, then computes and sums
    // the partial products of each part.
    const c2l0 = c2.lo & mulmask;
    const c2l1 = c2.lo >> mulshift;
    const c2h0 = c2.hi & mulmask;
    const c2h1 = c2.hi >> mulshift;

    const c1l0 = c1.lo & mulmask;
    ulong r0 = c1l0 * c2l0;
    ulong r1 = c1l0 * c2l1 + (r0 >> mulshift);
    ulong r2 = c1l0 * c2h0 + (r1 >> mulshift);
    ulong r3 = c1l0 * c2h1 + (r2 >> mulshift);

    const c1l1 = c1.lo >> mulshift;
    r1 = c1l1 * c2l0 + (r1 & mulmask);
    r2 = c1l1 * c2l1 + (r2 & mulmask) + (r1 >> mulshift);
    r3 = c1l1 * c2h0 + (r3 & mulmask) + (r2 >> mulshift);

    const c1h0 = c1.hi & mulmask;
    r2 = c1h0 * c2l0 + (r2 & mulmask);
    r3 = c1h0 * c2l1 + (r3 & mulmask) + (r2 >> mulshift);

    const c1h1 = c1.hi >> mulshift;
    r3 = c1h1 * c2l0 + (r3 & mulmask);

    const Cent ret = { lo:(r0 & mulmask) + (r1 & mulmask) * (mulmask + 1),
                       hi:(r2 & mulmask) + (r3 & mulmask) * (mulmask + 1) };
    return ret;
}


/****************************
 * Unsigned divide c1 / c2.
 * Params:
 *      c1 = dividend
 *      c2 = divisor
 * Returns:
 *      quotient c1 / c2
 */
pure
Cent core_udiv(Cent c1, Cent c2)
{
    Cent modulus;
    return core_udivmod(c1, c2, modulus);
}

/****************************
 * Unsigned divide c1 / c2. The remainder after division is stored to modulus.
 * Params:
 *      c1 = dividend
 *      c2 = divisor
 *      modulus = set to c1 % c2
 * Returns:
 *      quotient c1 / c2
 */
pure
Cent core_udivmod(Cent c1, Cent c2, out Cent modulus)
{
    //printf("udiv c1(%llx,%llx) c2(%llx,%llx)\n", c1.lo, c1.hi, c2.lo, c2.hi);
    // Based on "Unsigned Doubleword Division" in Hacker's Delight
    import core.bitop;

    // Divides a 128-bit dividend by a 64-bit divisor.
    // The result must fit in 64 bits.
    static ulong udivmod128_64(Cent c1, ulong c2, out ulong modulus)
    {
        // We work in base 2^^32
        enum base = 1UL << 32;
        enum divmask = (1UL << (Ubits / 2)) - 1;
        enum divshift = Ubits / 2;

        // Check for overflow and divide by 0
        if (c1.hi >= c2)
        {
            modulus = 0UL;
            return ~0UL;
        }

        // Computes [num1 num0] / den
        static uint udiv96_64(ulong num1, uint num0, ulong den)
        {
            // Extract both digits of the denominator
            const den1 = cast(uint)(den >> divshift);
            const den0 = cast(uint)(den & divmask);
            // Estimate ret as num1 / den1, and then correct it
            ulong ret = num1 / den1;
            const t2 = (num1 % den1) * base + num0;
            const t1 = ret * den0;
            if (t1 > t2)
                ret -= (t1 - t2 > den) ? 2 : 1;
            return cast(uint)ret;
        }

        // Determine the normalization factor. We multiply c2 by this, so that its leading
        // digit is at least half base. In binary this means just shifting left by the number
        // of leading zeros, so that there's a 1 in the MSB.
        // We also shift number by the same amount. This cannot overflow because c1.hi < c2.
        const shift = (Ubits - 1) - bsr(c2);
        c2 <<= shift;
        ulong num2 = c1.hi;
        num2 <<= shift;
        num2 |= (c1.lo >> (-shift & 63)) & (-cast(long)shift >> 63);
        c1.lo <<= shift;

        // Extract the low digits of the numerator (after normalizing)
        const num1 = cast(uint)(c1.lo >> divshift);
        const num0 = cast(uint)(c1.lo & divmask);

        // Compute q1 = [num2 num1] / c2
        const q1 = udiv96_64(num2, num1, c2);
        // Compute the true (partial) remainder
        const rem = num2 * base + num1 - q1 * c2;
        // Compute q0 = [rem num0] / c2
        const q0 = udiv96_64(rem, num0, c2);

        modulus = (rem * base + num0 - q0 * c2) >> shift;
        return (cast(ulong)q1 << divshift) | q0;
    }

    // Special cases
    if (!core_tst(c2))
    {
        // Divide by zero
        modulus = Zero;
        return core_com(modulus);
    }
    if (c1.hi == 0 && c2.hi == 0)
    {
        // Single precision divide
        const Cent rem = { lo:c1.lo % c2.lo };
        modulus = rem;
        const Cent ret = { lo:c1.lo / c2.lo };
        return ret;
    }
    if (c1.hi == 0)
    {
        // Numerator is smaller than the divisor
        modulus = c1;
        return Zero;
    }
    if (c2.hi == 0)
    {
        // Divisor is a 64-bit value, so we just need one 128/64 division.
        // If c1 / c2 would overflow, break c1 up into two halves.
        const q1 = (c1.hi < c2.lo) ? 0 : (c1.hi / c2.lo);
        if (q1)
            c1.hi = c1.hi % c2.lo;
        Cent rem;
        const q0 = udivmod128_64(c1, c2.lo, rem.lo);
        modulus = rem;
        const Cent ret = { lo:q0, hi:q1 };
        return ret;
    }

    // Full cent precision division.
    // Here c2 >= 2^^64
    // We know that c2.hi != 0, so count leading zeros is OK
    // We have 0 <= shift <= 63
    const shift = (Ubits - 1) - bsr(c2.hi);

    // Normalize the divisor so its MSB is 1
    // v1 = (c2 << shift) >> 64
    ulong v1 = core_shl(c2, shift).hi;

    // To ensure no overflow.
    Cent u1 = core_shr1(c1);

    // Get quotient from divide unsigned operation.
    ulong rem_ignored;
    const Cent q1 = { lo:udivmod128_64(u1, v1, rem_ignored) };

    // Undo normalization and division of c1 by 2.
    Cent quotient = core_shr(core_shl(q1, shift), 63);

    // Make quotient correct or too small by 1
    if (core_tst(quotient))
        quotient = core_dec(quotient);

    // Now quotient is correct.
    // Compute rem = c1 - (quotient * c2);
    Cent rem = core_sub(c1, core_mul(quotient, c2));

    // Check if remainder is larger than the divisor
    if (core_uge(rem, c2))
    {
        // Increment quotient
        quotient = core_inc(quotient);
        // Subtract c2 from remainder
        rem = core_sub(rem, c2);
    }
    modulus = rem;
    //printf("quotient "); print(quotient);
    //printf("modulus  "); print(modulus);
    return quotient;
}


/****************************
 * Signed divide c1 / c2.
 * Params:
 *      c1 = dividend
 *      c2 = divisor
 * Returns:
 *      quotient c1 / c2
 */
pure
Cent core_div(Cent c1, Cent c2)
{
    Cent modulus;
    return core_divmod(c1, c2, modulus);
}

/****************************
 * Signed divide c1 / c2. The remainder after division is stored to modulus.
 * Params:
 *      c1 = dividend
 *      c2 = divisor
 *      modulus = set to c1 % c2
 * Returns:
 *      quotient c1 / c2
 */
pure
Cent core_divmod(Cent c1, Cent c2, out Cent modulus)
{
    /* Muck about with the signs so we can use the unsigned divide
     */
    if (cast(long)c1.hi < 0)
    {
        if (cast(long)c2.hi < 0)
        {
            Cent r = core_udivmod(core_neg(c1), core_neg(c2), modulus);
            modulus = core_neg(modulus);
            return r;
        }
        Cent r = core_neg(core_udivmod(core_neg(c1), c2, modulus));
        modulus = core_neg(modulus);
        return r;
    }
    else if (cast(long)c2.hi < 0)
    {
        return core_neg(core_udivmod(c1, core_neg(c2), modulus));
    }
    else
        return core_udivmod(c1, c2, modulus);
}

/****************************
 * If c1 > c2 unsigned
 * Params:
 *      c1 = operand 1
 *      c2 = operand 2
 * Returns:
 *      true if c1 > c2
 */
pure
bool core_ugt(Cent c1, Cent c2)
{
    return (c1.hi == c2.hi) ? (c1.lo > c2.lo) : (c1.hi > c2.hi);
}

/****************************
 * If c1 >= c2 unsigned
 * Params:
 *      c1 = operand 1
 *      c2 = operand 2
 * Returns:
 *      true if c1 >= c2
 */
pure
bool core_uge(Cent c1, Cent c2)
{
    return !core_ugt(c2, c1);
}

/****************************
 * If c1 > c2 signed
 * Params:
 *      c1 = operand 1
 *      c2 = operand 2
 * Returns:
 *      true if c1 > c2
 */
pure
bool core_gt(Cent c1, Cent c2)
{
    return (c1.hi == c2.hi)
        ? (c1.lo > c2.lo)
        : (cast(long)c1.hi > cast(long)c2.hi);
}

/*******************************************************/

version (unittest)
{
    version (none)
    {
        import core.stdc.stdio;

        @trusted
        void print(Cent c)
        {
            printf("%lld, %lld\n", cast(ulong)c.lo, cast(ulong)c.hi);
            printf("x%llx, x%llx\n", cast(ulong)c.lo, cast(ulong)c.hi);
        }
    }
}

unittest
{
    const Cent C0 = Zero;
    const Cent C1 = One;
    const Cent C2 = { lo:2 };
    const Cent C3 = { lo:3 };
    const Cent C5 = { lo:5 };
    const Cent C10 = { lo:10 };
    const Cent C20 = { lo:20 };
    const Cent C30 = { lo:30 };
    const Cent C100 = { lo:100 };

    const Cent Cm1 =  core_neg(One);
    const Cent Cm3 =  core_neg(C3);
    const Cent Cm10 = core_neg(C10);

    const Cent C3_1 = { lo:1, hi:3 };
    const Cent C3_2 = { lo:2, hi:3 };
    const Cent C4_8  = { lo:8, hi:4 };
    const Cent C5_0  = { lo:0, hi:5 };
    const Cent C7_1 = { lo:1, hi:7 };
    const Cent C7_9 = { lo:9, hi:7 };
    const Cent C9_3 = { lo:3, hi:9 };
    const Cent C10_0 = { lo:0, hi:10 };
    const Cent C10_1 = { lo:1, hi:10 };
    const Cent C10_3 = { lo:3, hi:10 };
    const Cent C11_3 = { lo:3, hi:11 };
    const Cent C20_0 = { lo:0, hi:20 };
    const Cent C90_30 = { lo:30, hi:90 };

    const Cent Cm10_0 = core_inc(core_com(C10_0)); // Cent(lo=0,  hi=-10);
    const Cent Cm10_1 = core_inc(core_com(C10_1)); // Cent(lo=-1, hi=-11);
    const Cent Cm10_3 = core_inc(core_com(C10_3)); // Cent(lo=-3, hi=-11);
    const Cent Cm20_0 = core_inc(core_com(C20_0)); // Cent(lo=0,  hi=-20);

    enum Cent Cs_3 = { lo:3, hi:long.min };

    const Cent Cbig_1 = { lo:0xa3ccac1832952398, hi:0xc3ac542864f652f8 };
    const Cent Cbig_2 = { lo:0x5267b85f8a42fc20, hi:0 };
    const Cent Cbig_3 = { lo:0xf0000000ffffffff, hi:0 };

    /************************/

    assert( core_ugt(C1, C0) );
//    assert( ult(C1, C2) );
    assert( core_uge(C1, C0) );
//    assert( ule(C1, C2) );

    assert( !core_ugt(C0, C1) );
//    assert( !ult(C2, C1) );
    assert( !core_uge(C0, C1) );
//    assert( !ule(C2, C1) );

//    assert( !core_ugt(C1, C1) );
//    assert( !ult(C1, C1) );
    assert( core_uge(C1, C1) );
//    assert( ule(C2, C2) );

    assert( core_ugt(C10_3, C10_1) );
    assert( core_ugt(C11_3, C10_3) );
    assert( !core_ugt(C9_3, C10_3) );
    assert( !core_ugt(C9_3, C9_3) );

    assert( core_gt(C2, C1) );
    assert( !core_gt(C1, C2) );
    assert( !core_gt(C1, C1) );
    assert( core_gt(C0, Cm1) );
    assert( core_gt(Cm1, core_neg(C10)));
    assert( !core_gt(Cm1, Cm1) );
    assert( !core_gt(Cm1, C0) );

//    assert( !lt(C2, C1) );
//    assert( !le(C2, C1) );
//    assert( ge(C2, C1) );

    assert(core_neg(C10_0) == Cm10_0);
    assert(core_neg(C10_1) == Cm10_1);
    assert(core_neg(C10_3) == Cm10_3);

    assert(core_add(C7_1,C3_2) == C10_3);
    assert(core_sub(C1,C2) == Cm1);

    assert(core_inc(C3_1) == C3_2);
    assert(core_dec(C3_2) == C3_1);

    assert(core_shl(C10,0) == C10);
    assert(core_shl(C10,Ubits) == C10_0);
    assert(core_shl(C10,1) == C20);
    assert(core_shl(C10,Ubits * 2) == C0);
    assert(core_shr(C10_0,0) == C10_0);
    assert(core_shr(C10_0,Ubits) == C10);
    assert(core_shr(C10_0,Ubits - 1) == C20);
    assert(core_shr(C10_0,Ubits + 1) == C5);
    assert(core_shr(C10_0,Ubits * 2) == C0);
    assert(core_sar(C10_0,0) == C10_0);
    assert(core_sar(C10_0,Ubits) == C10);
    assert(core_sar(C10_0,Ubits - 1) == C20);
    assert(core_sar(C10_0,Ubits + 1) == C5);
    assert(core_sar(C10_0,Ubits * 2) == C0);
    assert(core_sar(Cm1,Ubits * 2) == Cm1);

//    assert(shl1(C10) == C20);
    assert(core_shr1(C10_0) == C5_0);
//    assert(sar1(C10_0) == C5_0);
//    assert(sar1(Cm1) == Cm1);

    Cent modulus;

    assert(core_udiv(C10,C2) == C5);
    assert(core_udivmod(C10,C2, modulus) ==  C5);   assert(modulus == C0);
    assert(core_udivmod(C10,C3, modulus) ==  C3);   assert(modulus == C1);
    assert(core_udivmod(C10,C0, modulus) == Cm1);   assert(modulus == C0);
    assert(core_udivmod(C2,C90_30, modulus) == C0); assert(modulus == C2);
    assert(core_udiv(core_mul(C90_30, C2), C2) == C90_30);
    assert(core_udiv(core_mul(C90_30, C2), C90_30) == C2);

    assert(core_div(C10,C3) == C3);
    assert(core_divmod( C10,  C3, modulus) ==  C3); assert(modulus ==  C1);
    assert(core_divmod(Cm10,  C3, modulus) == Cm3); assert(modulus == Cm1);
    assert(core_divmod( C10, Cm3, modulus) == Cm3); assert(modulus ==  C1);
    assert(core_divmod(Cm10, Cm3, modulus) ==  C3); assert(modulus == Cm1);
    assert(core_divmod(C2, C90_30, modulus) == C0); assert(modulus == C2);
    assert(core_div(core_mul(C90_30, C2), C2) == C90_30);
    assert(core_div(core_mul(C90_30, C2), C90_30) == C2);

    const Cent Cb1divb2 = { lo:0x4496aa309d4d4a2f, hi:ulong.max };
    const Cent Cb1modb2 = { lo:0xd83203d0fdc799b8, hi:ulong.max };
    assert(core_divmod(Cbig_1, Cbig_2, modulus) == Cb1divb2);
    assert(modulus == Cb1modb2);

    const Cent Cb1udivb2 = { lo:0x5fe0e9bace2bedad, hi:2 };
    const Cent Cb1umodb2 = { lo:0x2c923125a68721f8, hi:0 };
    assert(core_udivmod(Cbig_1, Cbig_2, modulus) == Cb1udivb2);
    assert(modulus == Cb1umodb2);

    const Cent Cb1divb3 = { lo:0xbfa6c02b5aff8b86, hi:ulong.max };
    const Cent Cb1udivb3 = { lo:0xd0b7d13b48cb350f, hi:0 };
    assert(core_div(Cbig_1, Cbig_3) == Cb1divb3);
    assert(core_udiv(Cbig_1, Cbig_3) == Cb1udivb3);

    assert(core_mul(Cm10, C1) == Cm10);
    assert(core_mul(C1, Cm10) == Cm10);
    assert(core_mul(C9_3, C10) == C90_30);
    assert(core_mul(Cs_3, C10) == C30);
    assert(core_mul(Cm10, Cm10) == C100);
    assert(core_mul(C20_0, Cm1) == Cm20_0);

    assert( core_or(C4_8, C3_1) == C7_9);
    assert(core_and(C4_8, C7_9) == C4_8);
    assert(core_xor(C4_8, C7_9) == C3_1);

//    assert(rol(Cm1,  1) == Cm1);
//    assert(ror(Cm1, 45) == Cm1);
//    assert(rol(ror(C7_9, 5), 5) == C7_9);
//    assert(rol(C7_9, 1) == rol1(C7_9));
//    assert(ror(C7_9, 1) == ror1(C7_9));
}
