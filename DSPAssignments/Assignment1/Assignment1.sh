#!/bin/bash

echo "A, B)"
octave 8bit.octave
echo ""
echo "C)"
octave 12bit.octave
echo ""
echo "There is less deviation and quantization error in the 12-bit converter."
echo ""
echo "D) No. The sampling rate is way over double the frequency, so the the wave cannot be contaminated with aliasing."
echo ""
echo "E) "
octave e.octave
echo ""
echo "F) "
echo "1st example) "
octave f1.octave
echo "2nd example) "
octave f2.octave
