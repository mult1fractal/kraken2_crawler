include { download_database_kraken2 } from './process/download_database_kraken2'
include { kraken2 } from './process/kraken2'
include { kraken2_each } from './process/kraken2'


workflow classifier_wf {
    take:   fastq
    main:   

           kraken2(fastq, download_database_kraken2())
           
    emit:   kraken2.out.kraken2_kreport_ch
}

workflow classifier_each_wf {
    take:   fastq
            each_kmer
    main:   

           kraken2_each(fastq, download_database_kraken2(), each_kmer)

    //emit:   kraken2.out.kraken2_each_kreport_ch, Access to 'kraken2.out' is undefined since process doesn't declare any output
}
