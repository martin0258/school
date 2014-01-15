#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2014 martinku <martinku@ss-martin-ku>
#
# Distributed under terms of the MIT license.

"""
Read node/edge CSV files, and write to a dot file.
"""
import sys
import csv
import re

node_setting = {
    'fillcolor': 'yellow',
    'style': 'filled',
    'fixedsize': 'true',
    'width': 1,
    'height': 1,
    'fontsize': 20
}

def add_node(node_file, out_file):
    f = open(node_file, 'r')
    out_file.write('  // node\n')
    for row in csv.DictReader(f):
        node_id = row['EventID']
        label = node_id
        fillcolor = 'green' if row['IsInitial'] == 'Y' else 'yellow'
        node = '  %s [label="%s", fillcolor="%s"];\n' % \
               (node_id, label, fillcolor)
        out_file.write(node)
    out_file.write('\n')
    f.close()

def add_edge(edge_file, out_file):
    f = open(edge_file, 'r')
    out_file.write('  // edge\n')
    for row in csv.DictReader(f):
        in_node = row['EventID']
        out_nodes = row['LinkToEventID'].split(',')
        ex_out_nodes = []
        for node in out_nodes:
            if '~' not in node:
                ex_out_nodes.append(node)
            else:
                nodes = expand_range(node)
                ex_out_nodes.extend(nodes)
        edge = '  %s -> { %s };\n' % (in_node, ' '.join(ex_out_nodes))
        # End of for
        out_file.write(edge)
    # End of for
    out_file.write('\n')
    f.close()

def expand_range(txt, range_operator='~'):
    """Return a list ['E1', 'E2', 'E3'] given 'E1~E3'."""
    if range_operator not in txt:
      return txt

    result = []
    index_pattern = r'(\D*)(\d+)'
    pair = txt.split(range_operator)
    result.append(pair[0])

    # Find start/end points
    match1 = re.search(index_pattern, pair[0])
    match2 = re.search(index_pattern, pair[1])
    start = int(match1.group(2))
    end = int(match2.group(2))
    label = match1.group(1) if match1.group(1) != match1.group(2) else ''
    result.extend([str(label) + str(i) for i in range(start + 1, end + 1)])
    return result


if __name__ == '__main__':
    if(len(sys.argv) != 4):
        print 'Error: number of arguments is incorrect.\n'
        print 'Usage: python %s [node.csv] [edge.csv] [graph.dot]' % sys.argv[0]
        sys.exit(0)
    node_file = sys.argv[1]
    edge_file = sys.argv[2]
    out_file = sys.argv[3]
    output = open(out_file, 'w')
    output.write('digraph {\n')
    setting = [key + '=' + str(value) for key, value in node_setting.items()]
    output.write('  node[%s]\n' % ','.join(setting))
    add_node(node_file, output)
    add_edge(edge_file, output)
    output.write('}\n')
    output.close()
