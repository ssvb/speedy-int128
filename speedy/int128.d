module speedy.int128;
/* code from https://github.com/ssvb/speedy-int128 (size: 16046, hash:8c44442f4) */ version(all){;;public struct Int128{@safe pure nothrow @nogc:version(LDC){alias shl=ldc_shl;alias shr=ldc_shr;alias sar=ldc_sar;alias xor=ldc_xor;alias and=ldc_and;alias or=ldc_or;alias add=ldc_add;alias inc=ldc_inc;alias dec=ldc_dec;alias com=ldc_com;alias gt=ldc_gt;alias tst=ldc_tst;static if(size_t.sizeof==8){alias div=ldc_div;alias divmod=ldc_divmod;alias mul=ldc_mul;alias sub=ldc_sub;alias neg=ldc_neg;}else{alias div=core_div;alias divmod=core_divmod;version(ARM){alias mul=core_mul;alias sub=core_sub;alias neg=core_neg;}else{alias mul=ldc_mul;alias sub=ldc_sub;alias neg=ldc_neg;}}}else{alias shl=core_shl;alias shr=core_shr;alias sar=core_sar;alias xor=core_xor;alias and=core_and;alias or=core_or;alias add=core_add;alias inc=core_inc;alias dec=core_dec;alias com=core_com;alias gt=core_gt;alias tst=core_tst;alias div=core_div;alias divmod=core_divmod;alias mul=core_mul;alias sub=core_sub;alias neg=core_neg;}Cent data;this(long lo){data.lo=lo;data.hi=lo<0?~0L:0;}this(ulong lo){data.lo=lo;data.hi=0;}this(long hi,long lo){data.hi=hi;data.lo=lo;}this(Cent data){this.data=data;}size_t toHash()const{return cast(size_t)((data.lo&0xFFFF_FFFF)+(data.hi&0xFFFF_FFFF)+(data.lo>>32)+(data.hi>>32));}bool opEquals(long lo)const{return data.lo==lo&&data.hi==(lo>>63);}bool opEquals(ulong lo)const{return data.hi==0&&data.lo==lo;}bool opEquals(Int128 op2)const{return data.hi==op2.data.hi&&data.lo==op2.data.lo;}Int128 opUnary(string op)()const if(op=="+"){return this;}Int128 opUnary(string op)()const if(op=="-"||op=="~"){static if(op=="-")return Int128(neg(this.data));else static if(op=="~")return Int128(com(this.data));}Int128 opUnary(string op)()if(op=="++"||op=="--"){static if(op=="++")this.data=inc(this.data);else static if(op=="--")this.data=dec(this.data);else static assert(0,op);return this;}bool opCast(T:bool)()const{return tst(this.data);}Int128 opBinary(string op)(Int128 op2)const if(op=="+"||op=="-"||op=="*"||op=="/"||op=="%"||op=="&"||op=="|"||op=="^"){static if(op=="+")return Int128(add(this.data,op2.data));else static if(op=="-")return Int128(sub(this.data,op2.data));else static if(op=="*")return Int128(mul(this.data,op2.data));else static if(op=="/")return Int128(div(this.data,op2.data));else static if(op=="%"){Cent modulus;divmod(this.data,op2.data,modulus);return Int128(modulus);}else static if(op=="&")return Int128(and(this.data,op2.data));else static if(op=="|")return Int128(or(this.data,op2.data));else static if(op=="^")return Int128(xor(this.data,op2.data));else static assert(0,"wrong op value");}Int128 opBinary(string op)(long op2)const if(op=="+"||op=="-"||op=="*"||op=="/"||op=="%"||op=="&"||op=="|"||op=="^"){return mixin("this "~ op ~" Int128(0, op2)");}Int128 opBinaryRight(string op)(long op2)const if(op=="+"||op=="-"||op=="*"||op=="/"||op=="%"||op=="&"||op=="|"||op=="^"){mixin("return Int128(0, op2) "~ op ~" this;");}Int128 opBinary(string op)(long op2)const if(op=="<<"){return Int128(shl(this.data,cast(uint)op2));}Int128 opBinary(string op)(long op2)const if(op==">>"){return Int128(sar(this.data,cast(uint)op2));}Int128 opBinary(string op)(long op2)const if(op==">>>"){return Int128(shr(this.data,cast(uint)op2));}ref Int128 opOpAssign(string op)(Int128 op2)if(op=="+"||op=="-"||op=="*"||op=="/"||op=="%"||op=="&"||op=="|"||op=="^"||op=="<<"||op==">>"||op==">>>"){mixin("this = this "~ op ~" op2;");return this;}ref Int128 opOpAssign(string op)(long op2)if(op=="+"||op=="-"||op=="*"||op=="/"||op=="%"||op=="&"||op=="|"||op=="^"||op=="<<"||op==">>"||op==">>>"){mixin("this = this "~ op ~" op2;");return this;}int opCmp(Int128 op2)const{return this==op2?0:gt(this.data,op2.data)*2-1;}int opCmp(long op2)const{return opCmp(Int128(0,op2));}enum min=Int128(long.min,0);enum max=Int128(long.max,ulong.max);}version(none){}}version(all){nothrow:@safe:@nogc:enum Ubits=uint(ulong.sizeof*8);struct Cent{version(LittleEndian){ulong lo;ulong hi;}else{ulong hi;ulong lo;}}enum Cent One={lo:1};enum Cent Zero={lo:0};enum Cent MinusOne=core_neg(One);pure bool core_tst(Cent c){return c.hi||c.lo;}pure Cent core_com(Cent c){c.lo=~c.lo;c.hi=~c.hi;return c;}pure Cent core_neg(Cent c){if(c.lo==0)c.hi= -c.hi;else{c.lo= -c.lo;c.hi=~c.hi;}return c;}pure Cent core_inc(Cent c){return core_add(c,One);}pure Cent core_dec(Cent c){return core_sub(c,One);}pure Cent core_shr1(Cent c){c.lo=(c.lo>>1)|((c.hi&1)<<(Ubits-1));c.hi>>=1;return c;}pure Cent core_shl(Cent c,uint n){if(n>=Ubits*2)return Zero;if(n>=Ubits){c.hi=c.lo<<(n-Ubits);c.lo=0;}else{c.hi=((c.hi<<n)|(c.lo>>(Ubits-n-1)>>1));c.lo=c.lo<<n;}return c;}pure Cent core_shr(Cent c,uint n){if(n>=Ubits*2)return Zero;if(n>=Ubits){c.lo=c.hi>>(n-Ubits);c.hi=0;}else{c.lo=((c.lo>>n)|(c.hi<<(Ubits-n-1)<<1));c.hi=c.hi>>n;}return c;}pure Cent core_sar(Cent c,uint n){const signmask= -(c.hi>>(Ubits-1));const signshift=(Ubits*2)-n;c=core_shr(c,n);if(n>=Ubits*2){c.hi=signmask;c.lo=signmask;}else if(signshift>=Ubits*2){}else if(signshift>=Ubits){c.hi&=~(ulong.max<<(signshift-Ubits));c.hi|=signmask<<(signshift-Ubits);}else{c.hi=signmask;c.lo&=~(ulong.max<<signshift);c.lo|=signmask<<signshift;}return c;}pure Cent core_and(Cent c1,Cent c2){const Cent ret={lo:c1.lo&c2.lo,hi:c1.hi&c2.hi};return ret;}pure Cent core_or(Cent c1,Cent c2){const Cent ret={lo:c1.lo|c2.lo,hi:c1.hi|c2.hi};return ret;}pure Cent core_xor(Cent c1,Cent c2){const Cent ret={lo:c1.lo ^ c2.lo,hi:c1.hi ^ c2.hi};return ret;}pure Cent core_add(Cent c1,Cent c2){ulong r=cast(ulong)(c1.lo+c2.lo);const Cent ret={lo:r,hi:cast(ulong)(c1.hi+c2.hi+(r<c1.lo))};return ret;}pure Cent core_sub(Cent c1,Cent c2){return core_add(c1,core_neg(c2));}pure Cent core_mul(Cent c1,Cent c2){enum mulmask=(1UL<<(Ubits/2))-1;enum mulshift=Ubits/2;const c2l0=c2.lo&mulmask;const c2l1=c2.lo>>mulshift;const c2h0=c2.hi&mulmask;const c2h1=c2.hi>>mulshift;const c1l0=c1.lo&mulmask;ulong r0=c1l0*c2l0;ulong r1=c1l0*c2l1+(r0>>mulshift);ulong r2=c1l0*c2h0+(r1>>mulshift);ulong r3=c1l0*c2h1+(r2>>mulshift);const c1l1=c1.lo>>mulshift;r1=c1l1*c2l0+(r1&mulmask);r2=c1l1*c2l1+(r2&mulmask)+(r1>>mulshift);r3=c1l1*c2h0+(r3&mulmask)+(r2>>mulshift);const c1h0=c1.hi&mulmask;r2=c1h0*c2l0+(r2&mulmask);r3=c1h0*c2l1+(r3&mulmask)+(r2>>mulshift);const c1h1=c1.hi>>mulshift;r3=c1h1*c2l0+(r3&mulmask);const Cent ret={lo:(r0&mulmask)+(r1&mulmask)*(mulmask+1),hi:(r2&mulmask)+(r3&mulmask)*(mulmask+1)};return ret;}pure Cent core_udiv(Cent c1,Cent c2){Cent modulus;return core_udivmod(c1,c2,modulus);}pure Cent core_udivmod(Cent c1,Cent c2,out Cent modulus){import core.bitop;static ulong udivmod128_64(Cent c1,ulong c2,out ulong modulus){enum base=1UL<<32;enum divmask=(1UL<<(Ubits/2))-1;enum divshift=Ubits/2;if(c1.hi>=c2){modulus=0UL;return ~0UL;}static uint udiv96_64(ulong num1,uint num0,ulong den){const den1=cast(uint)(den>>divshift);const den0=cast(uint)(den&divmask);ulong ret=num1/den1;const t2=(num1 % den1)*base+num0;const t1=ret*den0;if(t1>t2)ret-=(t1-t2>den)?2:1;return cast(uint)ret;}const shift=(Ubits-1)-bsr(c2);c2<<=shift;ulong num2=c1.hi;num2<<=shift;num2|=(c1.lo>>(-shift&63))&(-cast(long)shift>>63);c1.lo<<=shift;const num1=cast(uint)(c1.lo>>divshift);const num0=cast(uint)(c1.lo&divmask);const q1=udiv96_64(num2,num1,c2);const rem=num2*base+num1-q1*c2;const q0=udiv96_64(rem,num0,c2);modulus=(rem*base+num0-q0*c2)>>shift;return(cast(ulong)q1<<divshift)|q0;}if(!core_tst(c2)){modulus=Zero;return core_com(modulus);}if(c1.hi==0&&c2.hi==0){const Cent rem={lo:c1.lo % c2.lo};modulus=rem;const Cent ret={lo:c1.lo/c2.lo};return ret;}if(c1.hi==0){modulus=c1;return Zero;}if(c2.hi==0){const q1=(c1.hi<c2.lo)?0:(c1.hi/c2.lo);if(q1)c1.hi=c1.hi % c2.lo;Cent rem;const q0=udivmod128_64(c1,c2.lo,rem.lo);modulus=rem;const Cent ret={lo:q0,hi:q1};return ret;}const shift=(Ubits-1)-bsr(c2.hi);ulong v1=core_shl(c2,shift).hi;Cent u1=core_shr1(c1);ulong rem_ignored;const Cent q1={lo:udivmod128_64(u1,v1,rem_ignored)};Cent quotient=core_shr(core_shl(q1,shift),63);if(core_tst(quotient))quotient=core_dec(quotient);Cent rem=core_sub(c1,core_mul(quotient,c2));if(core_uge(rem,c2)){quotient=core_inc(quotient);rem=core_sub(rem,c2);}modulus=rem;return quotient;}pure Cent core_div(Cent c1,Cent c2){Cent modulus;return core_divmod(c1,c2,modulus);}pure Cent core_divmod(Cent c1,Cent c2,out Cent modulus){if(cast(long)c1.hi<0){if(cast(long)c2.hi<0){Cent r=core_udivmod(core_neg(c1),core_neg(c2),modulus);modulus=core_neg(modulus);return r;}Cent r=core_neg(core_udivmod(core_neg(c1),c2,modulus));modulus=core_neg(modulus);return r;}else if(cast(long)c2.hi<0){return core_neg(core_udivmod(c1,core_neg(c2),modulus));}else return core_udivmod(c1,c2,modulus);}pure bool core_ugt(Cent c1,Cent c2){return(c1.hi==c2.hi)?(c1.lo>c2.lo):(c1.hi>c2.hi);}pure bool core_uge(Cent c1,Cent c2){return !core_ugt(c2,c1);}pure bool core_gt(Cent c1,Cent c2){return(c1.hi==c2.hi)?(c1.lo>c2.lo):(cast(long)c1.hi>cast(long)c2.hi);}version(none){}}version(all){version(LDC){import ldc.llvmasm;;nothrow:@safe:@nogc:pure Cent ldc_divmod()(Cent c1,Cent c2,out Cent modulus){modulus=ldc_mod(c1,c2);return ldc_div(c1,c2);}pure Cent ldc_shl()(Cent a,uint b){auto tmp=__ir_pure!(` %4=zext i64 %1 to i128 %5=shl nuw i128 %4,64 %6=zext i64 %0 to i128 %7=or i128 %5,%6 %8=zext i32 %2 to i128 %9=shl i128 %7,%8 %10=trunc i128 %9 to i64 %11=lshr i128 %9,64 %12=trunc i128 %11 to i64 %13=insertvalue[2 x i64]undef,i64 %10,0 %14=insertvalue[2 x i64]%13,i64 %12,1 ret[2 x i64]%14`,long[2])(a.lo,a.hi,b);return Cent(tmp[0],tmp[1]);}pure Cent ldc_shr()(Cent a,uint b){auto tmp=__ir_pure!(` %4=zext i64 %1 to i128 %5=shl nuw i128 %4,64 %6=zext i64 %0 to i128 %7=or i128 %5,%6 %8=zext i32 %2 to i128 %9=lshr i128 %7,%8 %10=trunc i128 %9 to i64 %11=lshr i128 %9,64 %12=trunc i128 %11 to i64 %13=insertvalue[2 x i64]undef,i64 %10,0 %14=insertvalue[2 x i64]%13,i64 %12,1 ret[2 x i64]%14`,long[2])(a.lo,a.hi,b);return Cent(tmp[0],tmp[1]);}pure Cent ldc_sar()(Cent a,uint b){auto tmp=__ir_pure!(` %4=zext i64 %1 to i128 %5=shl nuw i128 %4,64 %6=zext i64 %0 to i128 %7=or i128 %5,%6 %8=zext i32 %2 to i128 %9=ashr i128 %7,%8 %10=trunc i128 %9 to i64 %11=lshr i128 %9,64 %12=trunc i128 %11 to i64 %13=insertvalue[2 x i64]undef,i64 %10,0 %14=insertvalue[2 x i64]%13,i64 %12,1 ret[2 x i64]%14`,long[2])(a.lo,a.hi,b);return Cent(tmp[0],tmp[1]);}pure Cent ldc_mul()(Cent a,Cent b){auto tmp=__ir_pure!(` %5=zext i64 %1 to i128 %6=shl nuw i128 %5,64 %7=zext i64 %0 to i128 %8=or i128 %6,%7 %9=zext i64 %3 to i128 %10=shl nuw i128 %9,64 %11=zext i64 %2 to i128 %12=or i128 %10,%11 %13=mul nsw i128 %12,%8 %14=trunc i128 %13 to i64 %15=lshr i128 %13,64 %16=trunc i128 %15 to i64 %17=insertvalue[2 x i64]undef,i64 %14,0 %18=insertvalue[2 x i64]%17,i64 %16,1 ret[2 x i64]%18`,long[2])(a.lo,a.hi,b.lo,b.hi);return Cent(tmp[0],tmp[1]);}pure Cent ldc_div()(Cent a,Cent b){auto tmp=__ir_pure!(` %5=zext i64 %1 to i128 %6=shl nuw i128 %5,64 %7=zext i64 %0 to i128 %8=or i128 %6,%7 %9=zext i64 %3 to i128 %10=shl nuw i128 %9,64 %11=zext i64 %2 to i128 %12=or i128 %10,%11 %13=sdiv i128 %8,%12 %14=trunc i128 %13 to i64 %15=lshr i128 %13,64 %16=trunc i128 %15 to i64 %17=insertvalue[2 x i64]undef,i64 %14,0 %18=insertvalue[2 x i64]%17,i64 %16,1 ret[2 x i64]%18`,long[2])(a.lo,a.hi,b.lo,b.hi);return Cent(tmp[0],tmp[1]);}pure Cent ldc_mod()(Cent a,Cent b){auto tmp=__ir_pure!(` %5=zext i64 %1 to i128 %6=shl nuw i128 %5,64 %7=zext i64 %0 to i128 %8=or i128 %6,%7 %9=zext i64 %3 to i128 %10=shl nuw i128 %9,64 %11=zext i64 %2 to i128 %12=or i128 %10,%11 %13=srem i128 %8,%12 %14=trunc i128 %13 to i64 %15=lshr i128 %13,64 %16=trunc i128 %15 to i64 %17=insertvalue[2 x i64]undef,i64 %14,0 %18=insertvalue[2 x i64]%17,i64 %16,1 ret[2 x i64]%18`,long[2])(a.lo,a.hi,b.lo,b.hi);return Cent(tmp[0],tmp[1]);}pure Cent ldc_xor()(Cent a,Cent b){auto tmp=__ir_pure!(` %5=zext i64 %1 to i128 %6=shl nuw i128 %5,64 %7=zext i64 %0 to i128 %8=or i128 %6,%7 %9=zext i64 %3 to i128 %10=shl nuw i128 %9,64 %11=zext i64 %2 to i128 %12=or i128 %10,%11 %13=xor i128 %12,%8 %14=trunc i128 %13 to i64 %15=lshr i128 %13,64 %16=trunc i128 %15 to i64 %17=insertvalue[2 x i64]undef,i64 %14,0 %18=insertvalue[2 x i64]%17,i64 %16,1 ret[2 x i64]%18`,long[2])(a.lo,a.hi,b.lo,b.hi);return Cent(tmp[0],tmp[1]);}pure Cent ldc_and()(Cent a,Cent b){auto tmp=__ir_pure!(` %5=zext i64 %1 to i128 %6=shl nuw i128 %5,64 %7=zext i64 %0 to i128 %8=or i128 %6,%7 %9=zext i64 %3 to i128 %10=shl nuw i128 %9,64 %11=zext i64 %2 to i128 %12=or i128 %10,%11 %13=and i128 %12,%8 %14=trunc i128 %13 to i64 %15=lshr i128 %13,64 %16=trunc i128 %15 to i64 %17=insertvalue[2 x i64]undef,i64 %14,0 %18=insertvalue[2 x i64]%17,i64 %16,1 ret[2 x i64]%18`,long[2])(a.lo,a.hi,b.lo,b.hi);return Cent(tmp[0],tmp[1]);}pure Cent ldc_or()(Cent a,Cent b){auto tmp=__ir_pure!(` %5=zext i64 %1 to i128 %6=shl nuw i128 %5,64 %7=zext i64 %0 to i128 %8=or i128 %6,%7 %9=zext i64 %3 to i128 %10=shl nuw i128 %9,64 %11=zext i64 %2 to i128 %12=or i128 %10,%11 %13=or i128 %12,%8 %14=trunc i128 %13 to i64 %15=lshr i128 %13,64 %16=trunc i128 %15 to i64 %17=insertvalue[2 x i64]undef,i64 %14,0 %18=insertvalue[2 x i64]%17,i64 %16,1 ret[2 x i64]%18`,long[2])(a.lo,a.hi,b.lo,b.hi);return Cent(tmp[0],tmp[1]);}pure Cent ldc_add()(Cent a,Cent b){auto tmp=__ir_pure!(` %5=zext i64 %1 to i128 %6=shl nuw i128 %5,64 %7=zext i64 %0 to i128 %8=zext i64 %3 to i128 %9=shl nuw i128 %8,64 %10=zext i64 %2 to i128 %11=or i128 %6,%7 %12=add i128 %11,%10 %13=add i128 %12,%9 %14=trunc i128 %13 to i64 %15=lshr i128 %13,64 %16=trunc i128 %15 to i64 %17=insertvalue[2 x i64]undef,i64 %14,0 %18=insertvalue[2 x i64]%17,i64 %16,1 ret[2 x i64]%18`,long[2])(a.lo,a.hi,b.lo,b.hi);return Cent(tmp[0],tmp[1]);}pure Cent ldc_sub()(Cent a,Cent b){auto tmp=__ir_pure!(` %5=zext i64 %1 to i128 %6=shl nuw i128 %5,64 %7=zext i64 %0 to i128 %8=zext i64 %3 to i128 %9=mul i128 %8,-18446744073709551616 %10=zext i64 %2 to i128 %11=or i128 %6,%7 %12=sub i128 %11,%10 %13=add i128 %12,%9 %14=trunc i128 %13 to i64 %15=lshr i128 %13,64 %16=trunc i128 %15 to i64 %17=insertvalue[2 x i64]undef,i64 %14,0 %18=insertvalue[2 x i64]%17,i64 %16,1 ret[2 x i64]%18`,long[2])(a.lo,a.hi,b.lo,b.hi);return Cent(tmp[0],tmp[1]);}pure Cent ldc_inc()(Cent a){auto tmp=__ir_pure!(` %3=zext i64 %1 to i128 %4=shl nuw i128 %3,64 %5=zext i64 %0 to i128 %6=add nuw nsw i128 %5,1 %7=add i128 %6,%4 %8=trunc i128 %7 to i64 %9=lshr i128 %7,64 %10=trunc i128 %9 to i64 %11=insertvalue[2 x i64]undef,i64 %8,0 %12=insertvalue[2 x i64]%11,i64 %10,1 ret[2 x i64]%12`,long[2])(a.lo,a.hi);return Cent(tmp[0],tmp[1]);}pure Cent ldc_dec()(Cent a){auto tmp=__ir_pure!(` %3=zext i64 %1 to i128 %4=shl nuw i128 %3,64 %5=zext i64 %0 to i128 %6=add nsw i128 %5,-1 %7=add i128 %6,%4 %8=trunc i128 %7 to i64 %9=lshr i128 %7,64 %10=trunc i128 %9 to i64 %11=insertvalue[2 x i64]undef,i64 %8,0 %12=insertvalue[2 x i64]%11,i64 %10,1 ret[2 x i64]%12`,long[2])(a.lo,a.hi);return Cent(tmp[0],tmp[1]);}pure Cent ldc_neg()(Cent a){auto tmp=__ir_pure!(` %3=zext i64 %1 to i128 %4=mul i128 %3,-18446744073709551616 %5=zext i64 %0 to i128 %6=sub i128 %4,%5 %7=trunc i128 %6 to i64 %8=lshr i128 %6,64 %9=trunc i128 %8 to i64 %10=insertvalue[2 x i64]undef,i64 %7,0 %11=insertvalue[2 x i64]%10,i64 %9,1 ret[2 x i64]%11`,long[2])(a.lo,a.hi);return Cent(tmp[0],tmp[1]);}pure Cent ldc_com()(Cent a){auto tmp=__ir_pure!(` %3=zext i64 %1 to i128 %4=shl nuw i128 %3,64 %5=zext i64 %0 to i128 %6=or i128 %4,%5 %7=xor i128 %6,-1 %8=trunc i128 %7 to i64 %9=lshr i128 %7,64 %10=trunc i128 %9 to i64 %11=insertvalue[2 x i64]undef,i64 %8,0 %12=insertvalue[2 x i64]%11,i64 %10,1 ret[2 x i64]%12`,long[2])(a.lo,a.hi);return Cent(tmp[0],tmp[1]);}pure bool ldc_gt()(Cent a,Cent b){return cast(bool)__ir_pure!(` %5=zext i64 %1 to i128 %6=shl nuw i128 %5,64 %7=zext i64 %0 to i128 %8=or i128 %6,%7 %9=zext i64 %3 to i128 %10=shl nuw i128 %9,64 %11=zext i64 %2 to i128 %12=or i128 %10,%11 %13=icmp sgt i128 %8,%12 %14=zext i1 %13 to i32 ret i32 %14`,int)(a.lo,a.hi,b.lo,b.hi);}pure bool ldc_tst()(Cent a){return cast(bool)__ir_pure!(` %3=zext i64 %1 to i128 %4=shl nuw i128 %3,64 %5=zext i64 %0 to i128 %6=or i128 %4,%5 %7=icmp ne i128 %6,0 %8=zext i1 %7 to i32 ret i32 %8`,int)(a.lo,a.hi);}}}
