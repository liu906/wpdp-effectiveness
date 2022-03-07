import sys
import os


#过滤一个跨版本模块的udb文件中的注释、空白和空行等
def FUNCTION_getFilteredCode(fileEntity):
    sEnt = fileEntity
    
    #返回值
    str_codeOneFile = ''
    
    file=startLine=endLine=''
    
    if sEnt.kind().check("file"):
        file = sEnt
        #模块在文件中起始和结束处对应的行号
        startLine = 1
        endLine = sEnt.metric(["CountLine"])["CountLine"]#返回的是dict，需要按照key取value
    else:
        file = sEnt.ref().file()
        #模块在文件中定义的起始和结束位置
        startRef = sEnt.refs("definein","",True)[0]
        endRef = sEnt.refs("end","",True)[0]
        #模块在文件中起始和结束处对应的行号 
        startLine = startRef.line()
        endLine = endRef.line()
    
    #文件的词法流指针
    lexer = file.lexer()
    
    #模块的token流指针（内容从起始行到结束行）
    lexemes = lexer.lexemes(startLine, endLine)

    length = len(lexemes)
    while (length == 0):
        endLine = endLine - 1
        lexemes = lexer.lexemes(startLine, endLine)
        length = len(lexemes)
    
    #当前的token是否在多个连续的空白符中间
    in_whitespace = 0
    
    #从第一个token依次往后扫描，将连续的多个空白符都替换为一个空格，其他内容不变
    for lexeme in lexemes:
        # 如果当前的token是空白符（包括注释、空格和换行）
        if ( lexeme.token() == "Comment" or lexeme.token() == "Whitespace" or lexeme.token() == "Newline"):
            #如果是第一个空白符
            if not in_whitespace:
                #在结果串上添加一个空格。不要添加空格，会造成一些语句的结果不正确。添加空格是为了人肉眼好看。
                str_codeOneFile = str_codeOneFile + ""
                #记住已经遇到了一个空白符
                in_whitespace = 1
        else:#如果不是空白符
            str_codeOneFile = str_codeOneFile + lexeme.text()
            in_whitespace = 0
        
    return str_codeOneFile

#按照跨版本模块的relName搜寻对应的文件实体
def FUNCTION_searchCrossVersionInstance_special(db,searchFileName,InstanceID_udbType):
    if InstanceID_udbType == 'file':
        allfiles = db.ents("file ~unknown ~unresolved")
        for file in allfiles:
            if file.relname().find(searchFileName)!=-1:
                return file
    if InstanceID_udbType == 'class':
        allfiles = db.ents('class ~unknown ~unresolved, interface ~unknown ~unresolved')
        for file in allfiles:
            if file.longname().find(searchFileName)!=-1:
                return file

#按照跨版本模块的relName搜寻对应的文件实体
def FUNCTION_searchCrossVersionInstance(db,searchFileName,InstanceID_udbType):
    if InstanceID_udbType == 'file':
        allfiles = db.ents("file ~unknown ~unresolved")
        for file in allfiles:
            if file.relname() == searchFileName:
                return file
    if InstanceID_udbType == 'class':
        allfiles = db.ents('class ~unknown ~unresolved, interface ~unknown ~unresolved')
        for file in allfiles:
            if file.longname() == searchFileName:
                return file
            
#读取udb中指定文件的代码
def FUNCTION_getStringFromModule(fileUdbPath_i_version,i_crossVersionModule,InstanceID_udbType,dataset_style):
#     fileUdbPath_i_version = "D:/test_old.udb"
    # Open Database
    db = understand.open(fileUdbPath_i_version)
    
    #从udb文件中找出该跨版本模块对应的文件实体
    if dataset_style in ["IND-JLMIV+R-2020","6M-SZZ-2020"]:
        fileEntity = FUNCTION_searchCrossVersionInstance_special(db,i_crossVersionModule,InstanceID_udbType)
    else:
        fileEntity = FUNCTION_searchCrossVersionInstance(db,i_crossVersionModule,InstanceID_udbType)
    #获得一个文件中的过滤过注释、空白和空行的代码
    str_codeOneFile = FUNCTION_getFilteredCode(fileEntity)
    # close database
    db.close()
    
    return str_codeOneFile

#'/'需替换成'\\'
def FUNCTION_separatorSubstitution(x):
    return x.replace("/", "\\")

if __name__ == '__main__':
    sys.path.append('/home/lau/software/scitools/bin/linux64/Python')#设置PYTHONPATH
    import understand
    understand_version = understand.version()
    print(understand_version)
    
    # dataset_style = "JIRA-RA-2019"
    dataset_style = "Metrics-Repo-2010"
    
    #udb的读取路径
    path_common_old = "./test/ant-1.3/"
    path_common_new = "./test/ant-1.4/"
    
    fileUdbPath_old = "./test/ant-1.3.udb"
    fileUdbPath_new = "./test/ant-1.4.udb"
    
    path_common_old = path_common_old + dataset_style + "/"
    path_common_new = path_common_new + dataset_style + "/"
    path_common_old = FUNCTION_separatorSubstitution(path_common_old)
    path_common_new = FUNCTION_separatorSubstitution(path_common_new)
    
    fileList = os.listdir(path_common_old)
    
    if dataset_style == "Metrics-Repo-2010":
        InstanceID = 'className'
        InstanceID_udbType = 'class'
    else:
        InstanceID = 'relName'
        InstanceID_udbType = 'file'
    
    for i_file in fileList:
        i_file_path = dataset_style + "\\" + i_file
        str_codeOneFile_old = FUNCTION_getStringFromModule(fileUdbPath_old,i_file_path,InstanceID_udbType,dataset_style)
        str_codeOneFile_new = FUNCTION_getStringFromModule(fileUdbPath_new,i_file_path,InstanceID_udbType,dataset_style)
        if str_codeOneFile_old == str_codeOneFile_new:
            print(str_codeOneFile_old)
            print(str_codeOneFile_new)
            print(i_file, ": same")
        else:
            print(i_file, ": not same")
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    