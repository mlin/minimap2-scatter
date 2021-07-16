version 1.1

workflow map_to_sharded_index {
    input {
        Array[File] index_shards
        File fastq
        File? fastq2
        String? minimap2_options

        String docker
    }

    # generate intermediate mappings from each index shard, then merge the intermediates
    # warning: minimap2_options (e.g. '-x sr') must be the same as used while indexing

    scatter (index_shard in index_shards) {
        call map {
            input:
            index_shard, fastq, fastq2, minimap2_options, docker
        }
    }

    call merge {
        input:
        intermediates = map.intermediate,
        fastq, fastq2, minimap2_options, docker
    }

    output {
        File mappings = merge.mappings
    }
}

task map {
    input {
        File index_shard
        File fastq
        File? fastq2
        String minimap2_options = ""

        String docker
        Int cpu = 8
    }

    command <<<
        set -euxo pipefail
        minimap2 ~{minimap2_options} -t ~{cpu} --split-map intermediate \
            '~{index_shard}' ~{fastq} ~{fastq2}
    >>>

    output {
        File intermediate = "intermediate"
    }

    runtime {
        docker: docker
        cpu: cpu
    }
}

task merge {
    input {
        Array[File] intermediates
        File fastq
        File? fastq2
        String minimap2_options = ""
        String output_basename = basename(fastq) + ".paf"

        String docker
    }

    command <<<
        set -euxo pipefail
        minimap2 ~{minimap2_options} --split-merge -o '~{output_basename}' \
            ~{fastq} ~{fastq2} . ~{sep(' ', squote(intermediates))}
    >>>

    output {
        File mappings = output_basename
    }

    runtime {
        docker: docker
    }
}