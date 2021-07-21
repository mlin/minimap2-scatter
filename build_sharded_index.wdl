version 1.1

workflow build_sharded_index {
    # split db_fasta into shards, then generate minimap2 index of each shard.
    # warning: the same minimap2_options (e.g. '-x sr') must be used for mapping & merging
    input {
        File db_fasta
        Int shards
        String? minimap2_options

        String docker
    }

    call split_db_fasta as split {
        input: db_fasta, shards, docker
    }

    scatter (shard_fasta in split.db_shards_fasta) {
        call index_shard as index {
            input: shard_fasta, minimap2_options, docker
        }
    }

    output {
        Array[File] index_shards = index.shard
    }
}

task split_db_fasta {
    input {
        File db_fasta
        Int shards

        String docker
        Int cpu = 4
    }

    command <<<
        set -euxo pipefail
        seqkit split2 '~{db_fasta}' -p ~{shards} -j ~{cpu} -O split
    >>>

    output {
        Array[File] db_shards_fasta = glob("split/*")
    }

    runtime {
        docker: docker
        cpu: cpu
    }
}

task index_shard {
    input {
        File shard_fasta
        String minimap2_options = ""
        String docker
    }

    String db_filename = "~{basename(shard_fasta)}.idx"

    command <<<
        set -euxo pipefail
        # set -I to NOT further split the shard
        minimap2 ~{minimap2_options} -I 9999G -d '~{db_filename}' '~{shard_fasta}'
    >>>

    output {
        File shard = db_filename
    }

    runtime {
        docker: docker
    }
}
