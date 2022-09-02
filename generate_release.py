#!/usr/bin/env python3

import os
import argparse

arg_parser = argparse.ArgumentParser()
arg_parser.add_argument('-u', '--users', help="Custom users file", default=False)
arg_parser.add_argument('-p', '--profiles', help="Custom profiles file", default=False)
args = arg_parser.parse_args()


running_folder = os.path.dirname(os.path.abspath(__file__))

install = [
'USERMODS/RAK0001.jcl',
'USERMODS/ZJW0003.jcl',
'TOOLS/RAKFCUST.jcl',
'AUX/VTOC/vtoc.jcl',
'AUX/CDSCB.jcl',
'TOOLS/VSAMSRAC.jcl',
'TOOLS/VTOCSRAC.jcl',
# 'TOOLS/VSAMLRAC.jcl',
# 'TOOLS/VTOCLRAC.jcl'
]

steps = []

def check_step(line, jcl_filename):
    if (' EXEC ' in line and
        line.split()[1] == 'EXEC' ):
        step_name = line.split()[0][2:]
        if step_name not in steps:
            steps.append(step_name)
        else:
            raise ValueError("Duplicate Step Name {} (from {}) Already exists".format(step_name, jcl_filename))

def read_file(filename):
    print("//*" + "*" * 66)
    print("//* {}".format("/".join(filename.split("/")[-2:]) ))
    print("//*" + "*" * 66)
    with open(filename, 'r') as f:
        jobcard = True

        for l in f.readlines():
            if l.strip() == "//":
                continue
            if not l.strip():
                continue
            if jobcard:
                if l.strip()[-1] == ",":
                    continue
                else:
                    jobcard = False
                    continue

            print(l.rstrip())
            check_step(l, filename)

def make_rakfcust(jclfile):
        done = False
        users = False
        find_end = False
        with open(running_folder + "/" + jclfile, 'r+') as f:
            text = f.read()
            f.seek(0)
            for line in text.split('\n'):
                if line != "/*" and find_end:
                    continue
                find_end = False
                f.write(line + "\n")
                if 'SYSUT1' in line and not users:
                    if not args.users:
                        users_file = "{}/{}".format(running_folder, args.users)
                    else:
                        users_file = args.users
                    with open( users_file, 'r') as users:
                        # RAKF expects things to be sorted words before numbers
                        # users_sorted = sorted(users.read().strip().split('\n'),key=test)
                        f.write("{}{}".format(users.read().strip(),"\n"))
                    users = True
                    find_end = True
                elif 'SYSUT1' in line and users and not done:
                    if not args.profiles:
                        profiles_file = "{}/{}".format(running_folder, args.profiles)
                    else:
                        profiles_file = args.profiles
                    with open(profiles_file, 'r') as profiles:
                    # profiles_sorted = sorted(profiles.read().strip().split('\n'), key=test)
                        f.write("{}{}".format(profiles.read().strip(),"\n"))
                    done = True
                    find_end = True
            f.truncate()
##################################################

with open(running_folder + "/TEMPLATES/01_header.template", 'r') as f:
    for l in f.readlines():
        print(l.rstrip())
        check_step(l, "01_header.template")

with open(running_folder + "/JCLIN/TRKF126.jcl") as f:
        print(f.read().rstrip())

smp_dict = {
        'MACLIB' : "++MAC({}) DISTLIB(AMACLIB)  SYSLIB(MACLIB).",
        'SRCLIB' : "++SRC({}) DISTLIB(ASRCLIB)  SYSLIB(SRCLIB).",
        'PROCLIB' : "++MAC({}) DISTLIB(APROCLIB) SYSLIB(PROCLIB).",
        'PARMLIB' : "++MAC({}) DISTLIB(APARMLIB) SYSLIB(PARMLIB)."
        }

folders = ["MACLIB", "SRCLIB", "PROCLIB", "PARMLIB"]

for folder in folders:
    fileList = os.listdir("{}/{}".format(running_folder,folder))

    for filename in fileList:
        print(smp_dict[folder].format(filename.split(".")[0]))
        jfile = os.path.join('{}/{}/{}'.format(running_folder,folder,filename))
        with open(jfile, 'r') as f:
            print(f.read().rstrip())

with open(running_folder + "/TEMPLATES/02_smp4.template", 'r') as f:
    for l in f.readlines():
        print(l.rstrip())
        check_step(l, "02_smp4.template")

for jcl in install:
    if 'RAKFCUST' in jcl:
        make_rakfcust(jcl)

    read_file(running_folder + "/" + jcl)

print("//* Steps in this job stream")

for i in steps:
    print("//* {}".format(i))
