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
    mkdir -p kraken_db && tar xfv ${database} -C kraken_db
    ##--strip-components 1

    kraken2 --db kraken_db --threads ${task.cpus} --output ${name}.kraken.out --report ${name}.kreport ${reads}

    # reduce footprint
    rm -rf kraken_db/
    """
    stub:
    """
    touch ${name}.kraken.out ${name}.kreport
    """
  }

process kraken2_each {
        label 'kraken2'
        publishDir "${params.output}/${name}", mode: 'copy'
    input:
        tuple val(name), path(reads)
        path(database)
        each k_mode
  	output:
    	  tuple val(name), path("${name}_*.kraken.out"), path("${name}_*.kreport"), emit: kraken2_each_kreport_ch
  	script:
    """
    mkdir -p kraken_db && tar xfv ${database} -C kraken_db
    ##--strip-components 1

    kraken2 \
      --db kraken_db \
      --threads ${task.cpus} \
      --minimum-hit-groups ${k_mode} \
      --output ${name}_${k_mode}.kraken.out \
      --report ${name}_${k_mode}.kreport \
      ${reads}

      # --classified-out \
      # --unclassified-out \

    # reduce footprint
    rm -rf kraken_db/
    """
    stub:
    """
    touch ${name}.kraken.out ${name}.kreport
    """
  }

/* 
how to build database
https://ccb.jhu.edu/software/kraken/MANUAL.html#custom-databases
nanozoo/kraken2:2.1.1--d5ded30
https://www.biorxiv.org/content/10.1101/2022.04.27.489753v1.full.pdf
https://github.com/DerrickWood/kraken2/issues/167
--confidence 0.05 or 0.1

In the docker to build new database:
install nano
cd /conda/libexec/rsync_from_ncbi.pl
in line 46 or so exchange ftp to:
if (! ($full_path =~ s#^https://${qm_server}${qm_server_path}/##)) {


kraken2-build --download-library archaea --db ncbi_kraken2_DB_19.08.22/
kraken2-build --download-library bacteria --db ncbi_kraken2_DB_19.08.22/
kraken2-build --download-library human --db ncbi_kraken2_DB_19.08.22/
kraken2-build --download-library viral --db ncbi_kraken2_DB_19.08.22/
fungi

  Hit group threshold: The option --minimum-hit-groups will allow you to require multiple hit 
  groups (a group of overlapping k-mers that share a common minimizer that is found in the hash table) be found before declaring a sequence classified, 
  which can be especially useful with custom databases when testing to see if sequences either do or do not belong to a particular genome.
  Sequence filtering: Classified or unclassified sequences can be sent to a file for later processing, using the --classified-out and --unclassified-out switches, respectively.

Output redirection: Output can be directed using standard shell redirection (| or >), or using the --output switch.

Compressed input: Kraken 2 can handle gzip and bzip2 compressed files as input by specifying the proper switch of --gzip-compressed or --bzip2-compressed.

Input format auto-detection: If regular files (i.e., not pipes or device files) are specified on the command line as input, 
Kraken 2 will attempt to determine the format of your input prior to classification. 
You can disable this by explicitly specifying --gzip-compressed or --bzip2-compressed as appropriate. 
Note that use of the character device file /dev/fd/0 to read from standard input (aka stdin) will not allow auto-detection.
   */