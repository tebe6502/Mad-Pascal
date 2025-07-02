loaderFile = "loader.xex"
headerFile = "head.bin"
comBlock = b'\x00\x24\xc1\x2b'

with open(loaderFile, 'rb') as infile:
    loader = infile.read()
    offset = loader.find(comBlock)
    if offset != -1:
        print 'com block found at:', offset
        offset += len(comBlock)
        print 'data offset: ', offset
    else:
        print 'com block not found in:', loaderFile
        exit();

with open(loaderFile, 'rb') as infile:
    print 'opening loader:', loaderFile
    head = infile.read(offset)
    infile.close()

with open(headerFile, 'wb+') as outfile:
    print 'ripping header to:', headerFile
    outfile.write(head)
    outfile.close()
