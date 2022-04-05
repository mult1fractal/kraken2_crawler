include { download_database_kraken2 } from './workflows/process/download_database_kraken2'
include { kraken2 } from './workflows/process/kraken2'


workflow classifier_wf {
    take:   fastq
    main:   
           download_database_kraken2()
           kraken2(fastq, kraken2_download_db.out )
    emit:   kraken2_results 
} 