# parse ping time
# ping -c 500 172.20.249.11 | awk '{print $7}' | awk -F "=" '{print $2}' > ping.log

f_path = 'ping.log'
lines = []
with open(f_path, 'r') as f:
    for l in f:
        if len(l.strip('\n')) > 0:
            lines.append(float(l.strip('\n')))

count = len(lines)
sum = 0
for l in lines:
    sum += l
avg = sum / count

lines.sort()
line_90 = lines[int(round(count * 0.9)) - 1]
line_99 = lines[int(round(count * 0.99)) - 1]
line_999 = lines[int(round(count * 0.999)) - 1]

# print(lines)
print('sampler count=%d, avg time=%.3f, line90=%.3f, line99=%.3f, line999=%.3f' % (count, avg, line_90, line_99, line_999))
