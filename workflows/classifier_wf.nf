include { download_database_kraken2 } from './process/download_database_kraken2'
include { kraken2 } from './process/kraken2'


workflow classifier_wf {
    take:   fastq
    main:   
           download_database_kraken2()

            if (!params.cloudProcess) { download_database_kraken2(); db = download_database_kraken2.out }
                // cloud storage via db_preload.exists()
                if (params.cloudProcess) {
                db_preload = file("${params.databases}/kraken2", type: 'dir')
                if (db_preload.exists()) { db = db_preload }
                else  { download_database_kraken2(); db = download_database_kraken2.out } 
                }


           kraken2(fastq, download_database_kraken2.out )
    emit:   kraken2.out.kraken2_kreport_ch
}