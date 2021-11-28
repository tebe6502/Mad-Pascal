#!/usr/bin/env python
# -*- coding: utf-8 -*-
__author__ = 'Wojciech Bocianski'
__email__ = 'bocianu@gmail.com'
__version__ = '0.0.1'

from subprocess import run
import os
import shutil
from time import sleep
from typing import Counter
from py65emu.cpu import CPU
from py65emu.mmu import MMU
import configparser
import random

class testUtils:
    validatedAttribs = ['START', 'MAIN.@EXIT']

    def __init__(self):
        cfile = "config.ini"
        if not os.path.exists(cfile):
            raise FileNotFoundError('config.ini file not found')
        self.config = configparser.ConfigParser()
        self.config.read(cfile)
        if not os.path.exists(self.config.get('paths','mp')):
            raise FileNotFoundError('MadPascal compiler not found here: {}'.format(self.config.get('paths','mp')))
        if not os.path.exists(self.config.get('paths','mads')):
            raise FileNotFoundError('MadAssembler not found here: {}'.format(self.config.get('paths','mads')))
        if not os.path.exists(self.config.get('paths','base')):
            raise FileNotFoundError('base directory not found here: {}'.format(self.config.get('paths','base')))
        self.clearRandoms()
        self.clearCounters()

    def validateLabel(self, label):
        labelname = "MAIN.{}".format(label.upper())
        if not labelname in self.labels:
            raise IndexError("Label not found: {}".format(labelname))
        return labelname
        

    def getLabels(self, tabfile):
        labels = {}
        with open(tabfile) as f:
            lines = f.readlines()
            if len(lines)>2:
                for linenum in range(2,len(lines)):
                    elems = lines[linenum].strip().split('\t')
                    labels[elems[2]]=int(elems[1],16)
        return labels


    def clearDir(self, dirname):
        if os.path.exists(dirname):
            shutil.rmtree(dirname)
        os.makedirs(dirname)    
       
        
    def buildBinary(self, pasfile):
        # prepare paths
        dirname = os.path.dirname(pasfile)
        rawname = os.path.splitext(os.path.basename(pasfile))[0]
        srcasmfile = "{}/{}.a65".format(dirname, rawname)
        rawpath = "{}/{}".format(self.config.get('paths','tempdir'),rawname)
        asmfile = "{}.a65".format(rawpath)
        binfile = "{}.bin".format(rawpath)
        tabfile = "{}.tab".format(rawpath)
        
        # compile and validate
        rc = run("{} {} -t raw".format(self.config.get('paths','mp'), pasfile), shell = True)
        if rc.returncode != 0 :
            raise NotImplementedError("Mad-Pascal exit code = {}. Probably compilation error occured".format(rc.returncode))
        if not os.path.exists(srcasmfile):
            raise NotImplementedError("File {} not found! Probably compilation error occured".format(srcasmfile))
                        
        # copy assembly file to tempdir if needed
        if srcasmfile != asmfile: 
            rc = shutil.move(srcasmfile, asmfile)
            while not os.path.exists(asmfile):
                sleep(0.1)
        
        # assemby file and validate
        rc = run("{} {} -x -i:{} -t:{} -o:{}".format(self.config.get('paths','mads'), asmfile, self.config.get('paths','base'), tabfile, binfile), shell = True)
        if rc.returncode != 0:
            raise NotImplementedError("Mad-Assembler exit code = {}. Probably nasty assemblation error occured".format(rc.returncode))

        # parse all labels
        self.labels = self.getLabels(tabfile)

        # check for required labels
        for attrib in self.validatedAttribs:
            if not attrib in self.labels:
                raise IndexError("Label not found: {}".format(attrib))

        return binfile
        
  
    def runEmu(self):
    # this method executes code until reaches end of program, or hits breakpoint
    # it returns False on breakpoints and True on the end of code reached  
        timeout = int(self.config.get('params','cpuTimeout'), 16)
        while self.c.r.pc != self.labels['MAIN.@EXIT']:
            self.c.step()
            self.cmdCount += 1
            
            # check for timeout
            if self.cmdCount > timeout:
                raise TimeoutError("CPU timeouted after {} commands".format(self.cmdCount))
            
            # check for breakpoints
            if len(self.breakpointadressess) > 0:
                if self.c.r.pc in self.breakpointadressess:
                    return False

            # check if there is something to randomize
            if len(self.randoms) > 0:
                for address in self.randoms:
                    self.m.write(address, random.randint(255))
            
            # check if there are counters to increment
            if len(self.counters) > 0:
                for address in self.counters:
                    curval = self.m.read(address)
                    curval = (curval + 1) % 256
                    self.m.write(address, curval)

        return True
        
        
    def runBinary(self, pasfile, breakpointlabels, randoms, counters):    
    # breakpointlabels is a list of labels to stop emulation on program counter hit

        # prepare binary file
        binfile = self.buildBinary(pasfile)
        binstart = int(self.config.get('params','binaryLocation'),16)
        memsize = int(self.config.get('params','memorySize'),16)
        
        # load into emulator memory
        with open(binfile, "rb") as filedata:
            self.m = MMU([
                (0, binstart), 
                (binstart, binstart + memsize, False, filedata) 
            ])

        # initialize cpu
        self.c = CPU(self.m, self.labels['START'])
        self.cmdCount = 0

        # add user defined random registers
        if len(randoms) > 0:
            for item in randoms:
                self.randoms.append(item)

        # add user defined counters
        if len(counters) > 0:
            for item in counters:
                self.counters.append(item)

        # update randoms converting labels to direct addresses
        for value in self.randoms:
            if not isinstance(value, int):
                labelname = self.validateLabel(value.upper())
                self.randoms.remove(value)
                self.randoms.append(self.labels[labelname])
        
        # update counters converting labels to direct addresses
        for value in self.counters:
            if not isinstance(value, int):
                labelname = self.validateLabel(value.upper())
                self.counters.remove(value)
                self.counters.append(self.labels[labelname])

        # convert breakpoint labels into addresses
        self.breakpointadressess = []
        if len(breakpointlabels) > 0:
            for blabel in breakpointlabels:
                labelname = self.validateLabel(blabel.upper())
                self.breakpointadressess.append(self.labels[labelname])
                
        # make sure all elements are unique
        self.randoms = list(set(self.randoms))                
        self.counters = list(set(self.counters))                
        self.breakpointadressess = list(set(self.breakpointadressess))                

        self.runEmu()
        return [self.c,self.m,self.labels]

    def setRandomByte(self, address):
        self.randoms.append(address)
    
    def setCounterByte(self, address):
        self.counters.append(address)

    def clearRandoms(self):
        self.randoms = []
    
    def clearCounters(self):
        self.counters = []        

#############################        
# TEST RUNNER API           #      
#############################
            
    def runFile(self, pasfile, breakpoints = [], randoms = [], counters = []):
    # breakpointlabels is a list of labels to stop emulation on program counter hit
        self.clearDir(self.config.get('paths','tempdir'))
        return self.runBinary(pasfile, breakpoints, randoms, counters)
        
    def runCode(self, pascode, breakpoints = [], randoms = [], counters = []):
    # breakpointlabels is a list of labels to stop emulation on program counter hit
        self.clearDir(self.config.get('paths','tempdir'))
        pasfile = "{}/temp.pas".format(self.config.get('paths','tempdir'))
        with open(pasfile, 'w') as f:
            f.write(pascode)
        return self.runBinary(pasfile, breakpoints, randoms, counters)

    def resume(self):
        self.runEmu()
        return [self.c,self.m,self.labels]

#############################        
# VARIABLE AND DATA GETTERS #      
#############################
    
    def varByte(self, varlabel):
        labelname = self.validateLabel(varlabel)
        return self.m.read(self.labels[labelname])
     
    def varWord(self, varlabel):
        labelname = self.validateLabel(varlabel)
        return self.m.readWord(self.labels[labelname])

    def varCardinal(self, varlabel):
        labelname = self.validateLabel(varlabel)
        upper = self.m.readWord(self.labels[labelname]) 
        lower = self.m.readWord(self.labels[labelname] + 2) 
        return (lower << 16) + upper

    def getByte(self, address):
        return self.m.read(address)

    def getWord(self, address):
        return self.m.readWord(address)

    def getCardinal(self, address):
        upper = self.m.readWord(address) 
        lower = self.m.readWord(address + 2) 
        return (lower << 16) + upper
        
    def getArray(self, address, size, element_size = 1):
        resultArray = []
        elemAddress = address
        for i in range(size):
            byteshift = 0
            elem = 0
            for ebyte in range(element_size):
                elem += self.m.read(elemAddress) << byteshift
                byteshift += 8
                elemAddress += 1
                
            resultArray.append(elem)
        return resultArray

    def isVarTrue(self, varlabel):
        labelname = self.validateLabel(varlabel)
        return self.m.read(self.labels[labelname]) == self.labels['TRUE']

    def isTrue(self, address):
        return self.m.read(address) == self.labels['TRUE']
