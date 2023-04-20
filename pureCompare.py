"""
compare two udb file
"""
import sys
import os
import pandas as pd
import sys
if sys.platform.startswith('linux'):
    print("running on Linux")
    sys.path.append('/root/scitools/bin/linux64/Python') # 设置PYTHONPATH

else:
    print("Running on Windows")

import understand
import argparse
print('sciTool Understand version: ', understand.version())


def compareFile(old_db, new_db):
    #TODO: check function of compare file
    res = pd.DataFrame(columns=['old', 'new', 'isSame'])
    old_modules = old_db.ents("file ~unknown ~unresolved")
    new_modules = new_db.ents("file ~unknown ~unresolved")
    for new_module in new_modules:
        # longname '/home/lau/project/udb/Metrics-Repo-2010/ant/ant/ant-1.3/src/antidote/org/apache/tools/ant/gui/wizard/ButtonNavigator.java'
        # relname 'ant-1.3/src/antidote/org/apache/tools/ant/gui/wizard/ButtonNavigator.java'
        # name 'ButtonNavigator.java'

        # new_longname = new_module.longname()

        new_relname = new_module.relname()
        new_relname = os.path.normpath(new_relname)
        new_relname_except_root = os.path.join(*new_relname.split(os.sep)[1:])
        new_relname_nameOnly = new_relname.split(os.sep)[-1]

        os.path.split(new_relname)
        isFind = False
        idx = 0
        while (not isFind) and (idx < len(old_modules)):
            old_relname = old_modules[idx].relname()
            old_relname = os.path.normpath(old_relname)
            old_relname_except_root = os.path.join(*old_relname.split(os.sep)[1:])
            old_relname_nameOnly = old_relname.split(os.sep)[-1]


            #if old_relname_except_root == new_relname_except_root:
            # if the requriment is both filename and path should be equal, then old_relname_except_root == new_relname_except_root
            # if the requriment is only the filename should be equal, then old_relname_nameOnly == new_relname_nameOnly
            if old_relname_nameOnly == new_relname_nameOnly:
                isFind = True
                break
            idx = idx + 1
        if not isFind:
            continue
        old_module = old_modules[idx]
        try:
            old_lexer = old_module.lexer()
            new_lexer = new_module.lexer()
            old_lexemes = old_lexer.lexemes()
            new_lexemes = new_lexer.lexemes()
            new_idx = 0;
            old_idx = 0;
            flag = True
            while flag and new_idx < len(new_lexemes) and old_idx < len(old_lexemes):
                while new_idx < len(new_lexemes) and (
                        new_lexemes[new_idx].token() == 'Comment' or new_lexemes[new_idx].token() == 'Whitespace' or
                        new_lexemes[new_idx].token() == 'Newline'):
                    new_idx = new_idx + 1
                while old_idx < len(old_lexemes) and (
                        old_lexemes[old_idx].token() == 'Comment' or old_lexemes[old_idx].token() == 'Whitespace' or
                        old_lexemes[old_idx].token() == 'Newline'):
                    old_idx = old_idx + 1
                if (old_lexemes[old_idx].text() != new_lexemes[new_idx].text()):
                    flag = False
                new_idx = new_idx + 1
                old_idx = old_idx + 1
            if (new_idx == len(new_lexemes) and old_idx == len(old_lexemes)):
                #print('####same', old_relname_except_root, new_relname_except_root)
                res.loc[len(res.index)] = [old_relname_except_root, new_relname_except_root, True]
            else:
                #print('$$$$diff', old_relname, new_relname)
                res.loc[len(res.index)] = [old_relname_except_root, new_relname_except_root, False]
        except:
            print('UnableCreateLexer, Skip')
            print(old_relname, new_relname)
    return res

def compareClass(old_db, new_db):
    res = pd.DataFrame(columns=['old', 'new', 'isSame'])

    old_modules = old_db.ents("class ~unknown ~unresolved, interface ~unknown ~unresolved")
    new_modules = new_db.ents("class ~unknown ~unresolved, interface ~unknown ~unresolved")

    for new_module in new_modules:
        new_longname = new_module.longname()
        isFind = False
        idx = 0
        while (not isFind) and (idx < len(old_modules)):
            old_longname = old_modules[idx].longname()
            if old_longname == new_longname:
                isFind = True
                break
            idx = idx + 1
        if not isFind:
            continue
        old_module = old_modules[idx]
        try:
            old_lexer = old_module.lexer()
            new_lexer = new_module.lexer()
            old_lexemes = old_lexer.lexemes()
            new_lexemes = new_lexer.lexemes()
            new_idx = 0;
            old_idx = 0;
            flag = True
            while flag and new_idx < len(new_lexemes) and old_idx < len(old_lexemes):
                while new_idx < len(new_lexemes) and (
                        new_lexemes[new_idx].token() == 'Comment' or new_lexemes[new_idx].token() == 'Whitespace' or
                        new_lexemes[new_idx].token() == 'Newline'):
                    new_idx = new_idx + 1
                while old_idx < len(old_lexemes) and (
                        old_lexemes[old_idx].token() == 'Comment' or old_lexemes[old_idx].token() == 'Whitespace' or
                        old_lexemes[old_idx].token() == 'Newline'):
                    old_idx = old_idx + 1
                if (old_lexemes[old_idx].text() != new_lexemes[new_idx].text()):
                    flag = False
                new_idx = new_idx + 1
                old_idx = old_idx + 1
            if (new_idx == len(new_lexemes) and old_idx == len(old_lexemes)):
                #print('####same', old_longname, new_longname)
                res.loc[len(res.index)] = [old_longname, new_longname, True]
            else:
                #print('$$$$diff', old_longname, new_longname)
                res.loc[len(res.index)] = [old_longname, new_longname, False]
        except:
            print('UnableCreateLexer, Skip')
            print(old_longname, new_longname)
    return res


def compare(old_udb_path, new_udb_path, old_release_name, new_release_name, module_type, dataset):
    res_path = './dataset/diff/' + dataset
    resname = res_path + '/' + old_release_name + '_' + new_release_name + '_' + module_type + '.csv'
    if os.path.exists(resname):
        return
    print('process: ', resname)
    if not os.path.exists(res_path):
        os.makedirs(res_path)
        print("create result dir")

    old_db = understand.open(old_udb_path)
    new_db = understand.open(new_udb_path)

    if module_type == 'file':
        res = compareFile(old_db, new_db)
    elif module_type == 'class':
        res = compareClass(old_db, new_db)
    old_db.close()
    new_db.close()
    res.to_csv(resname, index=False)


def test():
    old_udb_path = "./udb/Metrics-Repo-2010/ant/ant-1.3.udb"
    new_udb_path = "./udb/Metrics-Repo-2010/ant/ant-1.4.udb"
    old_release_name = 'ant-1.3'
    new_release_name = 'ant-1.4'
    module_type = 'class'
    compare(old_udb_path, new_udb_path, old_release_name, new_release_name, module_type)

if __name__ == '__main__':

    parser = argparse.ArgumentParser(
        description="use this script to analyze the same and different modules in two consecutive releases")

    parser.add_argument("old_udb_path", help='the path of udb file of an old release')
    parser.add_argument("new_udb_path", help='the path of udb file of a new release')
    parser.add_argument("old_release_name", help='the name of old release')
    parser.add_argument("new_release_name", help='the name of new release')
    parser.add_argument("module_type", help='the module type to be analyzed, file or class')
    parser.add_argument("dataset", help='dataset name')

    args = parser.parse_args()
    old_udb_path = args.old_udb_path
    new_udb_path = args.new_udb_path
    old_release_name = args.old_release_name
    new_release_name = args.new_release_name
    module_type = args.module_type
    dataset = args.dataset
    compare(old_udb_path, new_udb_path, old_release_name, new_release_name, module_type, dataset)

