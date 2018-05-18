
cpucuda="gcc CpuMat.c -o Output/out"

sharedcuda="nvcc Shared.cu -o Output/out -Wno-deprecated-gpu-targets"
globalcuda="nvcc Global.cu -o Output/out -Wno-deprecated-gpu-targets"
globalthrd="nvcc globalthrd.cu -o Output/out -Wno-deprecated-gpu-targets"

read -p "Enter four matrix sizes : " m1 m2 m3 m4 
read -p "Enter four thread size : " t1 t2 t3 t4
size=( $m1 $m2 $m3 $m4)
tread=($t1 $t2 $t3 $t4)



	if [ -e "Output/cpu.dat" ] 
	then
		rm -rf "Output/cpu.dat"
		touch "Output/cpu.dat"
	else
		touch "Output/cpu.dat"
	fi
	if [ -e "Output/global.dat" ] 
	then
		rm -rf "Output/global.dat"
		touch "Output/global.dat"
	else
		touch "Output/global.dat"
	fi
	if [ -e "Output/shared.dat" ] 
	then
		rm -rf "Output/shared.dat"
		touch "Output/shared.dat"
	else
		touch "Output/shared.dat"
	fi

	if [ -e "Output/globalthread.dat" ] 
	then
		rm -rf "Output/globalthread.dat"
		touch "Output/globalthread.dat"
	else
		touch "Output/globalthread.dat"
	fi


echo -e "\nCPU Timer with given matrix size\n"
eval $cpucuda

for i in "${size[@]}"
do :
	total="0"
	repeat="4"
	for j in `seq 1 $repeat`
	do :
		result=$(./Output/out $i)
		total=$(bc <<< "scale=10; $total+$result")
	done
	avg=$(bc <<< "scale=8; $total/$repeat")
	echo "$i size of matrix take $avg seconds"
	printf "( $i, $avg )\n" >> "Output/cpu.dat"
done


echo  -e "\nGPU Global Timer with given matrix size\n"
eval $globalcuda

for i in "${size[@]}"
do :
	total="0"
	repeat="4"
	for j in `seq 1 $repeat`
	do :
		result=$(./Output/out $i $tread)
		total=$(bc <<< "scale=8; $total+$result")
	done
	avg=$(bc <<< "scale=10; $total/$repeat")
	echo "$i size of matrix take $avg seconds"
	printf "( $i, $avg )\n" >> "Output/global.dat"
done


echo -e "\nGPU Shared Timer with given matrix size\n"
eval $sharedcuda

for i in "${size[@]}"
do :
	total="0"
	repeat="4"
	for j in `seq 1 $repeat`
	do :
		result=$(./Output/out $i)
		total=$(bc <<< "scale=8; $total+$result")
	done
	avg=$(bc <<< "scale=10; $total/$repeat")
	echo "$i size of matrix take $avg seconds"
	printf "( $i, $avg )\n" >> "Output/shared.dat"
done



echo -e "\nGPU Global Timer with given thread size\n"
eval $globalthrd

for i in "${tread[@]}"
do :
	total="0"
	repeat="4"
	for j in `seq 1 $repeat`
	do :
		result=$(./Output/out $i)
		total=$(bc <<< "scale=8; $total+$result")
	done
	avg=$(bc <<< "scale=10; $total/$repeat")
	echo "$i size of thread using matrix take $avg seconds"
	printf "( $i, $avg )\n" >> "Output/globalthread.dat"
done


echo "Process is completed"
echo "Now Generating pdf..."
cd Output
pdflatex Report.tex
echo "Report.pdf is create successfully"
