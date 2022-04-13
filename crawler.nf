#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
* Nextflow -- kraken2
* Author: MQT
*/

/* 
Nextflow version check  
Format is this: XX.YY.ZZ  (e.g. 20.07.1)
change below
*/

XX = "21"
YY = "04"
ZZ = "0"

if ( nextflow.version.toString().tokenize('.')[0].toInteger() < XX.toInteger() ) {
println "\033[0;33mWtP requires at least Nextflow version " + XX + "." + YY + "." + ZZ + " -- You are using version $nextflow.version\u001B[0m"
exit 1
}
else if ( nextflow.version.toString().tokenize('.')[1].toInteger() == XX.toInteger() && nextflow.version.toString().tokenize('.')[1].toInteger() < YY.toInteger() ) {
println "\033[0;33mWtP requires at least Nextflow version " + XX + "." + YY + "." + ZZ + " -- You are using version $nextflow.version\u001B[0m"
exit 1
}


if (params.help) { exit 0, helpMSG() }

println " "
println "\u001B[32mProfile: $workflow.profile\033[0m"
println " "
println "\033[2mCurrent User: $workflow.userName"
println "Nextflow-version: $nextflow.version"
println "Starting time: $nextflow.timestamp"
println "Workdir location [--workdir]:"
println "  $workflow.workDir"
println "Output location [--output]:"
println "  $params.output"
println "\033[2mDatabase location [--databases]:"
println "  $params.databases\u001B[0m"
println " "
println "\033[2mCPUs per process: $params.cores, maximal CPUs to use: $params.max_cores\033[0m"
println " "

/************* 
* ERROR HANDLING
*************/
// profiles
if ( workflow.profile == 'standard' ) { exit 1, "NO VALID EXECUTION PROFILE SELECTED, use e.g. [-profile local,docker]" }

if (
    workflow.profile.contains('ukj_cloud') ||
    workflow.profile.contains('stub') ||
    workflow.profile.contains('docker')
    ) { "engine selected" }
else { exit 1, "No engine selected:  -profile EXECUTER,ENGINE" }

if (
    workflow.profile.contains('local') ||
    workflow.profile.contains('ukj_cloud') ||
    workflow.profile.contains('stub')
    ) { "executer selected" }
else { exit 1, "No executer selected:  -profile EXECUTER,ENGINE" }


/************* 
* INPUT HANDLING
*************/

// fastq input or via csv file
    if (params.fastq && params.list ) { 
        fastq_input_ch = Channel
        .fromPath( params.fastq, checkIfExists: true )
        .splitCsv()
        .map { row -> ["${row[0]}", file("${row[1]}", checkIfExists: true)] }
    }
    else if (params.fastq ) { 
        fastq_input_ch = Channel
        .fromPath( params.fastq, checkIfExists: true)
        .map { file -> tuple(file.simpleName, file) }
    }
// eachfile input 
    if (params.each_file) { each_file_input_ch = Channel
        .fromPath( params.each_file, checkIfExists: true)
        // .splitCsv(header: true, sep: ',')
        .splitCsv(header: true)
        .map { row -> ( "${row.kmers}")}
        .toList()
        .view() //////////////////////////////////needs to be split to list
    }

/************************** 
* Workflows to call
**************************/

include { classifier_wf } from './workflows/classifier_wf.nf'
include { classifier_each_wf } from './workflows/classifier_wf.nf'




/************************** 
* Workflow
**************************/

workflow {
    if (params.fastq && !params.each_file) { classifier_wf(fastq_input_ch) }
    if (params.fastq && params.each_file) { classifier_each_wf(fastq_input_ch, each_file_input_ch ) }

}
/*************  
* --help
*************/
def helpMSG() {
    c_green = "\033[0;32m";
    c_reset = "\033[0m";
    c_yellow = "\033[0;33m";
    c_blue = "\033[0;34m";
    c_dim = "\033[2m";
    log.info """
    .
    ${c_yellow}Usage examples:${c_reset}
    nextflow run crawler.nf --fastq \\
                            --cores 20 \\
                            --max_cores 40 \\
                            --output results \\
                            -profile local,docker \\
                            --databases 
                            --each_file

    working each-command
    nextflow run crawler.nf --fastq test_fastqs/115_stat_deep.fastq.gz --each_file test_fastqs/each_file.csv --cores 20 -profile local,docker -work-dir /media/6tb_1/work/

    """.stripIndent()
}


workflow.onComplete { 
        log.info ( workflow.success ? "\nDone! Results are stored here --> $params.output \n" : "Oops .. something went wrong" )
    
}
