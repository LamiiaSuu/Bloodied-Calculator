import sys

if len(sys.argv) < 2:
    print("<HP> [Hurt States]")
    sys.exit(1)

zahl = int(sys.argv[1])
schritte = int(sys.argv[2]) if len(sys.argv) > 2 else 4

for i in range(1, schritte):
    prozent = (schritte - i) * 100 // schritte
    wert = zahl * (schritte - i) // schritte

    print(f"{prozent}% = {wert}")