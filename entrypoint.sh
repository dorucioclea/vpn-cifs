#!/bin/sh
echo $ANYCONNECT_PASSWORD | openconnect --authgroup $ANYCONNECT_GROUP $ANYCONNECT_SERVER --user=$ANYCONNECT_USER --timestamp