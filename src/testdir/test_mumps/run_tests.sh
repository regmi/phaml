#!/bin/sh

# Script to run PHAML tests of MUMPS

THISDIR="test_mumps"
echo "PHAML TEST:"
echo "PHAML TEST: $THISDIR: tests of MUMPS"

if [ $PHAML_MUMPS = "no" ]
then
   echo "PHAML TEST:"
   echo "PHAML TEST: MUMPS not included in PHAML compilation"
   echo "PHAML TEST: Skipping tests."
   exit 0
fi

echo "PHAML TEST: Compile tests in $THISDIR"
make -s all
PASS=$?

if [ $PASS != 0 ]
then
   echo "PHAML TEST:"
   echo "PHAML TEST: FAILURE Unable to compile tests in $THISDIR."
   exit 1
fi

ERR=0
RUN1="$RUNMPI -np 1 "
if [ $PHAML_PARALLEL = "sequential" ]
then
   RUN1=
fi

case "$PHAML_PARALLEL" in
   messpass_spawn) FORM="ms" ;;
   messpass_nospawn) FORM="spmd" ;;
   sequential) FORM="seq" ;;
esac

for PROG in `ls test*.f90`;
do
   TESTN=`echo $PROG | sed -e s/\.f90//`
   echo "PHAML TEST: Run test $THISDIR/$TESTN"
   $RUN1 ./$TESTN.exe > $TESTN.out
   PASS=$?
   if [ $PASS != 0 ]
   then
      echo "PHAML TEST:"
      echo "PHAML TEST: FAILURE $THISDIR/$TESTN failed to run"
      ERR=1
   else
      diff $TESTN.out $TESTN.$FORM.comp > $TESTN.diff
      PASS=$?
      if [ $PASS = 2 ]
      then
         echo "PHAML TEST:"
         echo "PHAML TEST: FAILURE $THISDIR/$TESTN diff failed"
         ERR=1
      else
         DIFFSIZE=`cat $TESTN.diff | wc -l`
         if [ $DIFFSIZE = 0 ]
         then
            echo "PHAML TEST: SUCCESS for $THISDIR/$TESTN"
         else
            echo "PHAML TEST:"
            echo "PHAML TEST: WARNING -- $THISDIR/$TESTN.out differs from the expected"
            echo "PHAML TEST:            results in $THISDIR/$TESTN.$FORM.comp."
            echo "PHAML TEST:            Examine $THISDIR/$TESTN.diff"
            echo "PHAML TEST:            to see if the difference is significant."
            echo "PHAML TEST:"
         fi
      fi
   fi
done

exit $ERR
