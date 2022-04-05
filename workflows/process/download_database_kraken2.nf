process download_database_kraken2 {
        label "ubuntu"
        storeDir "${params.databases}/kraken2"
        errorStrategy 'retry'
        maxRetries 1
    output:
        path("kraken.tar.gz")
    script:

        """
        echo ${task.attempt}
        wget --no-check-certificate https://figshare.com/articles/dataset/GTDB_r89_54k/8956970?file=16378256 -O kraken.tar.gz
        """
  
    stub:
        """
        touch kraken.tar.gz
        """
}
