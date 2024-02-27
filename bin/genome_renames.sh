for i in *fna; do
    gen_name=$(basename "$i" | awk -F'_' '{print $1"_"$2}')
    echo $gen_name 
    sed -i "s/^>/&$(gen_name)_%_/" $i
done
