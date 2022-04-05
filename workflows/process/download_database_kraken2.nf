process download_database_kraken2 {
        label "ubuntu"
        storeDir "${params.databases}/kraken2"
        errorStrategy 'retry'
        maxRetries 1
    output:
        path("gtdb_r89_54k_centrifuge.tar")
    script:

        """
        echo ${task.attempt}
        wget --no-check-certificate https://monash.figshare.com/ndownloader/files/16378439 -O gtdb_r89_54k_centrifuge.tar
        """
  
    stub:
        """
        touch gtdb_r89_54k_centrifuge.tar
        """
}
