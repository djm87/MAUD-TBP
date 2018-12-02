#! /bin/sh -f
MAUD_PATH=`dirname "$0"`
cd $MAUD_PATH
MAUD_PATH=`pwd`
./jre1.8.0_131/bin/java -XX:ParallelGCThreads=1 -mx8192M -Duser.dir=$MAUD_PATH -cp lib/Maud.jar:lib/ij.jar com.radiographema.MaudText -file $MAUD_PATH/We43.ins

