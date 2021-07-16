version 1.1
import "build_sharded_index.wdl" as index
import "map_to_sharded_index.wdl" as map

workflow demo {
    input {
        File db_fasta
        Int shards = 4
        File fastq
        File? fastq2
        String minimap2_options = "-cx sr"

        String docker = "minimap2-scatter"
    }

    # Build & map to the sharded index
    call index.build_sharded_index {
        input: db_fasta, shards, minimap2_options, docker
    }

    call map.map_to_sharded_index {
        input:
        index_shards = build_sharded_index.index_shards,
        fastq, fastq2, minimap2_options, docker
    }

    # Run unsharded minimap2 as a control
    call control {
        input: db_fasta, fastq, fastq2, minimap2_options
    }

    output {
        File mappings = map_to_sharded_index.mappings
        File control_mappings = control.mappings
    }
}

task control {
    input {
        File db_fasta
        File fastq
        File? fastq2
        String? minimap2_options
        String output_basename = basename(fastq) + ".control.paf"
    }

    command <<<
        set -euxo pipefail
        apt-get -qq update && apt-get -qq install -y minimap2 2>&1
        minimap2 ~{minimap2_options} -o '~{output_basename}' \
            '~{db_fasta}' '~{fastq}' ~{"'" + fastq2 + "'"}
    >>>

    output {
        File mappings = output_basename
    }

    runtime {
        docker: "ubuntu:21.04"
        cpu: 8
    }
}
