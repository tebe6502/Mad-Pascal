import array


class MemoryRangeError(ValueError):
    pass


class ReadOnlyError(TypeError):
    pass


class MMU:
    def __init__(self, blocks):
        """
        Initialize the MMU with the blocks specified in blocks.  blocks
        is a list of 5-tuples, (start, length, readonly, value, valueOffset).

        See `addBlock` for details about the parameters.
        """

        # Different blocks of memory stored seperately so that they can
        # have different properties.  Stored as dict of "start", "length",
        # "readonly" and "memory"
        self.blocks = []

        for b in blocks:
            self.addBlock(*b)

    def reset(self):
        """
        In all writeable blocks reset all values to zero.
        """
        for b in self.blocks:
            if not b['readonly']:
                b['memory'] = array.array('B', [0]*b['length'])

    def addBlock(self, start, length, readonly=False, value=None, valueOffset=0):
        """
        Add a block of memory to the list of blocks with the given start address
        and length; whether it is readonly or not; and the starting value as either
        a file pointer, binary value or list of unsigned integers.  If the
        block overlaps with an existing block an exception will be thrown.

        Parameters
        ----------
        start : int
            The starting address of the block of memory
        length : int
            The length of the block in bytes
        readOnly: bool
            Whether the block should be read only (such as ROM) (default False)
        value : file pointer, binary or lint of unsigned integers
            The intial value for the block of memory. Used for loading program
            data. (Default None)
        valueOffset : integer
            Used when copying the above `value` into the block to offset the
            location it is copied into. For example, to copy byte 0 in `value`
            into location 1000 in the block, set valueOffest=1000. (Default 0)
        """

        # check if the block overlaps with another
        for b in self.blocks:
            if ((start+length > b['start'] and start+length < b['start']+b['length']) or
                    (b['start']+b['length'] > start and b['start']+b['length'] < start+length)):
                raise MemoryRangeError()

        newBlock = {
            'start': start, 'length': length, 'readonly': readonly,
            'memory': array.array('B', [0]*length)
        }

        # TODO: implement initialization value
        if type(value) == list:
            for i in range(len(value)):
                newBlock['memory'][i+valueOffset] = value[i]

        elif value is not None:
            a = array.array('B')
            a.frombytes(value.read())
            for i in range(len(a)):
                newBlock['memory'][i+valueOffset] = a[i]

        self.blocks.append(newBlock)

    def getBlock(self, addr):
        """
        Get the block associated with the given address.
        """

        for b in self.blocks:
            if addr >= b['start'] and addr < b['start']+b['length']:
                return b

        raise IndexError

    def getIndex(self, block, addr):
        """
        Get the index, relative to the block, of the address in the block.
        """
        return addr-block['start']

    def write(self, addr, value):
        """
        Write a value to the given address if it is writeable.
        """
        b = self.getBlock(addr)
        if b['readonly']:
            raise ReadOnlyError()

        i = self.getIndex(b, addr)

        b['memory'][i] = value & 0xff

    def read(self, addr):
        """
        Return the value at the address.
        """
        b = self.getBlock(addr)
        i = self.getIndex(b, addr)
        return b['memory'][i]

    def readWord(self, addr):
        return (self.read(addr+1) << 8) + self.read(addr)
