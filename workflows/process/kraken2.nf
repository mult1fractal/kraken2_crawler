process kraken2 {
        label 'kraken2'
        publishDir "${params.output}/${name}", mode: 'copy'
    input:
        tuple val(name), path(reads)
        path(database)
  	output:
    	tuple val(name), path("${name}.kraken.out"), path("${name}.kreport"), emit: kraken2_kreport_ch
  	script:
    """
    mkdir -p kraken_db && tar xfvz ${database} -C kraken_db --strip-components 1

    kraken2 --db kraken_db --threads ${task.cpus} --output ${name}.kraken.out --report ${name}.kreport masked_reads.fastq

    # reduce footprint
    rm -rf kraken_db/
    """
    stub:
    """
    touch ${name}.kraken.out ${name}.kreport
    """
  }