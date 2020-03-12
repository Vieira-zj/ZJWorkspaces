# -*- coding: utf-8 -*-
import os
import sys

def parse_ping_time(f_path):
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
    summay = 'sampler count=%d, avg time=%.3f, line90=%.3f, line99=%.3f, line999=%.3f' % (count, avg, line_90, line_99, line_999)
    print(summay)
    with open('ping_summary.txt', 'w') as output:
        output.write(summay)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        raise Exception('Please input ping log file path!')

    # input = os.path.join(os.getcwd(), sys.argv[1])
    input = sys.argv[1]
    if not os.path.exists(input):
        raise Exception('Input ping log file (%s) not found!' % input)
    parse_ping_time(input)
    print('parse ping time done.')
