import subprocess
# import sys
# import os

# os.system("start /wait cmd /c make rebuild_proj")

make_command = "make py_gui"
makefile_dir = "../../"
subprocess_output = subprocess.Popen(make_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, cwd=str(makefile_dir))
print("PY: Return code: {}".format(subprocess_output.returncode))