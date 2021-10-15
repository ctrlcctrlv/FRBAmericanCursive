#!/usr/bin/env python3
#:!(python3 scripts/letter_combos.py > specimens/combos.sil) && (sile specimens/combos.sil && firefox specimens/combos.pdf)
import string
import math
import os

fontfamily = os.environ["FONTFAMILY"]

print(r"""
\begin[papersize=1.4ft x 0.8ft]{{document}}
    \script[src=packages/color-fonts]
    \script[src=packages/rules]
    \font[filename=dist/{}-400-GuidelinesArrowsRegular.otf,size=1.5em]{{""".format(fontfamily)[1:])

combos_from_string=lambda s: [list(zip(e*len(s), s)) for e in s]
lets=combos_from_string(string.ascii_lowercase)
combos_gen=lambda w1, w2, L: [" ".join(["{}{}".format(w1(f),w2(s)) for (f,s) in let]) for let in L]
combos = combos_gen(lambda f: f, lambda s: s, lets)
PAR=r"\par "
HRULE=r"\par\hrule[width=100%fw,height=0.1em]"
EJECT=r"\eject"
print(((" "*8)+PAR)+("\n"+((" "*8)+PAR)).join(combos))
print((" "*8)+HRULE)
print((" "*8)+PAR+(" ".join(string.ascii_lowercase)))
print((" "*8)+EJECT)
print(((" "*8)+PAR)+("\n"+((" "*8)+PAR)).join(combos_gen(lambda f: f.upper(), lambda s: s, lets)))
print((" "*8)+HRULE)
print((" "*8)+PAR+(" ".join(string.ascii_uppercase)))
print((" "*8)+EJECT)
print(((" "*8)+PAR)+("\n"+((" "*8)+PAR)).join([c.upper() for c in combos]))
digits=[list(zip(e*len(string.digits), string.digits)) for e in string.digits]
dcombos_n=lambda n: [" ".join(["{n}{}{}".format(f,s,n=n) for (f,s) in digitl]) for digitl in digits]
print((" "*8)+HRULE)
print((" "*8)+(PAR+("FRB"*12)))
print((" "*8)+EJECT)
args = [str(i) for i in range(10)]+[""]
pop_front_or = lambda L, o: L.pop(0) if len(L) > 0 else o
dcombos_nL = [[pop_front_or(args, "") for j in range(2)] for i in range(math.ceil(len(args)/2))]
for a1, a2 in dcombos_nL:
    print(((" "*8)+PAR)+("\n"+((" "*8)+PAR)).join([z[0]+" "+z[1] for z in zip(dcombos_n(a1), dcombos_n(a2))]))
print((" "*8)+EJECT)
print((" "*8)+EJECT)
cyrl_lower="".join([chr(c) for c in list(range(0x430, 0x44F+1))])
cyrl_upper=cyrl_lower.upper()
cyrl_lets=combos_from_string(cyrl_lower)
cyrl_combos = combos_gen(lambda f: f, lambda s: s, cyrl_lets)
print(((" "*8)+PAR)+("\n"+((" "*8)+PAR)).join(cyrl_combos))
print((" "*8)+HRULE)
print((" "*8)+PAR+(" ".join(cyrl_lower)))
print((" "*8)+EJECT)
print(((" "*8)+PAR)+("\n"+((" "*8)+PAR)).join(combos_gen(lambda f: f.upper(), lambda s: s, cyrl_lets)))
print((" "*8)+HRULE)
print((" "*8)+PAR+(" ".join(cyrl_upper)))
print((" "*8)+EJECT)
print(((" "*8)+PAR)+("\n"+((" "*8)+PAR)).join([c.upper() for c in cyrl_combos]))
print((" "*8)+HRULE)
miscs=list("~¡¢£¥¦§«­°µ¶·»¿ÆÇ×ØÞßæçð÷øþıŒœȷ !@#$")+[r"\%"]+list("^&*(){}<>?/")
print((" "*8)+PAR+(" ".join(miscs)))

print(r"""}
\end{document}
""")
