for i in *.kreport; do
    minimum_hit_groups=$(echo $i | cut -d"." -f1| cut -d"_" -f4)
    uline=$(grep "unclassified" $i)
    echo "overlapping k-mers sharing the same minimizer: $minimum_hit_groups | Unclassified: $uline "
done


for i in *.kreport; do
    minimum_hit_groups=$(echo $i | cut -d"." -f1| cut -d"_" -f4)
    uline=$(grep "unclassified" $i)
    echo "overlapping k-mers sharing the same minimizer: $minimum_hit_groups | Unclassified: $uline "
done

grep -f organism list *kreport  > report_per_minimum_hit_groups.report
