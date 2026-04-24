int andOp(int a, int b) => a & b;
int orOp(int a, int b) => a | b;
int xorOp(int a, int b) => a ^ b;
int notOp(int a, int bits) => (~a) & ((1 << bits) - 1);
int shl(int a, int shift) => a << shift;
int shr(int a, int shift) => a >> shift;

String toBin(int n) => n.toRadixString(2);
String toHex(int n) => n.toRadixString(16).toUpperCase();
String toOct(int n) => n.toRadixString(8);
int fromHex(String s) => int.parse(s, radix: 16);
int fromBin(String s) => int.parse(s, radix: 2);
int fromOct(String s) => int.parse(s, radix: 8);