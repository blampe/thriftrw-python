# Copyright (c) 2015 Uber Technologies, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

from __future__ import absolute_import, unicode_literals, print_function

from libc.stdint cimport int32_t

from . cimport mtype

from thriftrw._cython cimport richcompare

__all__ = ['Message']


cdef class Message(object):
    """A Message envelope for Thrift requests and responses.

    .. py:attribute:: name

        Name of the method being called.

    .. py:attribute:: seqid

        ID of the message used by the client to match responses to requests.
        The server's contract is to return the same ``seqid`` in the response
        that it received in the request.

    .. py:attribute:: message_type

        Message type of the message. See :py:mod:`thriftrw.wire.ttype`.

    .. py:attribute:: body

        Message payload. The value here depends on the message type.


    Requests and responses **must** be wrapped in a ``Message`` if you are
    making requests to Apache Thrift services or receiving requests from
    clients generated by Apache Thrift.

    See :ref:`calling-apache-thrift` for more information.

    .. versionadded:: 1.0
    """

    def __cinit__(self, name, int32_t seqid, int message_type, body):
        if not isinstance(name, bytes):
            self.name = name.encode('utf-8')
        else:
            self.name = <bytes>name
        self.seqid = seqid
        self.message_type = message_type
        self.body = body

    def __richcmp__(Message self, Message other not None, int op):
        return richcompare(op, [
            (self.name, other.name),
            (self.seqid, other.seqid),
            (self.body, other.body),
            (self.message_type, other.message_type),
        ])

    def __str__(self):
        return 'Message(%r, %r, %r, %r)' % (
            self.name, self.seqid, mtype.name_of(self.message_type), self.body
        )

    def __repr__(self):
        return str(self)
