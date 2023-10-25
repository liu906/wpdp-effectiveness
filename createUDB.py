import glob
import os
import sys
if sys.platform == 'win32':
    os.add_dll_directory(r"C:\Program Files\SciTools\bin\pc-win64")
    import understand

elif sys.platform == 'linux':
    print('platform error, please use windows to extract udb file form scitool Understand')

import csv
import logging
import subprocess
import time

def extract_basic_metrics(project_path):
    # Open the Understand database project
    db = understand.open(project_path)

    # Get all files in the project
    files = db.ents("File")

    # Extract metrics for each file
    for file in files:
        print(f"File: {file.longname()}")
        print(f"Lines of Code: {file.metric(['CountLineCode'])}")
        print(f"Number of Classes: {file.metric(['CountDeclClass'])}")
        print(f"Number of Functions/Methods: {file.metric(['CountDeclFunction'])}")

    # Close the Understand database
    db.close()


def create_udb(udb_path, udb_name, language, project_root):
    # if os.path.exists(udb_path + '/' + udb_name + '.csv'):
    #     print('metrics csv already exists! skip!')
    #     return
    try:
        output = subprocess.check_output(
            "und create -db {udb_path}/{udb_name} -languages {lang}".format(udb_path=udb_path, udb_name=udb_name, lang=language),
            shell=True)
        logging.info(output)
        output = subprocess.check_output("und add -db {udb_path}/{udb_name} {project}".format(
            udb_path=udb_path, udb_name=udb_name, project=project_root), shell=True)
        logging.info(output)
        '''
        und settings -reportOutputDirectory c:\htmlDir c:\project.und
        und settings -metrics all c:project.und
        und settings -metricsOutputFile c:metrics.csv c:\project.und
        und analyze c:\project.und
        und report c:\project.und
        und metrics c:\project.und
        '''
        # output = subprocess.check_output("und settings -db {udb_path}/{udb_name} -reportOutputDirectory {udb_path}".format(
        #     udb_path=udb_path, udb_name=udb_name), shell=True)
        # logging.info(output)
        output = subprocess.check_output("und analyze {udb_path}/{udb_name}".format(
            udb_path=udb_path, udb_name=udb_name), shell=True)
        logging.info(output)

    except subprocess.CalledProcessError as e:
        logging.exception(e.output)
        logging.fatal("udb creation failed")
        raise Exception

def create_udb_for_projects():
    # root_path = 'D:/work/cross-version/udb/'
    # pattern = '*/*/*/*/'
    # projects = glob.glob(root_path+pattern)
    # for project in projects:
    #     if project==root_path:
    #         continue
    #     if 'JIRA-HA' in project:
    #         continue
    #
    #     print(project)
    #     project_path = project
    #     tail=''
    #     while tail=='':
    #         head, tail = os.path.split(project)
    #         project = head
    #
    #     create_udb(udb_path=head, udb_name=tail, language='Java', project_root=project_path)
    #     print(project_path + ' create finished')
    root_path = 'D:/work/cross-version/udb/'
    pattern = '*/*/*/*/'
    projects = glob.glob(root_path + pattern)

    # 创建一个 CSV 文件并写入表头
    csv_file_path = 'result/TimeComplexity/CreateUDB_time_complexity_IND.csv'
    os.makedirs('result/TimeComplexity/', exist_ok=True)

    with open(csv_file_path, mode='a', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(['Project Name', 'Project Path', 'Time Spent'])

        for project in projects:
            if project == root_path:
                continue
            if 'JIRA-HA' in project:
                continue
            if not 'IND-JLMIV+R-2020' in project:
                continue

            project_path = project
            tail = ''
            while tail == '':
                head, tail = os.path.split(project)
                project = head

            start_time = time.time()  # 记录开始时间

            create_udb(udb_path=head, udb_name=tail, language='Java', project_root=project_path)

            end_time = time.time()  # 记录结束时间
            time_spent = end_time - start_time  # 计算花费时间

            # 将信息写入 CSV 文件
            with open(csv_file_path, mode='a', newline='') as file:
                writer = csv.writer(file)
                writer.writerow([tail, project_path, time_spent])

            print(project_path + ' create finished')


if __name__ == "__main__":
    for i in range(2):
        create_udb_for_projects()


