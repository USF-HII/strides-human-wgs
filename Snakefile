
configfile: os.environ.get("CONFIG", "config.yaml")

if os.environ.get("SAMPLES_LIMIT"):
    SAMPLES_LIMIT = int(os.environ["SAMPLES_LIMIT"])
else:
    SAMPLES_LIMIT = None

SAMPLES = config["samples"][:SAMPLES_LIMIT]

rule all:
    input:
        expand("work/sort/{sample}.txt", sample=SAMPLES)

rule namesort_cram_to_bam:
    input:
        ref_fa="data/ref/hs38DH.fa",
        ref_fai="data/ref/hs38DH.fa.fai",
        cram="data/{sample}.cram"
    output:
        bam="work/namesort_cram_to_bam/{sample}.bam"
    resources:
        mem_mb=32_000, disk_mb=200_000
    threads:
        2
    conda:
        "environment.yaml"
    shell:
        """
        samtools sort --threads={threads} -m 3500M --no-PG --reference={input.ref_fa} -T {output.bam}.tmp -n -o {output.bam} {input.cram}
        """

rule bam_to_fq:
    input:
        bam="work/namesort_cram_to_bam/{sample}.bam"
    output:
        fq_1="work/bam_to_fq/{sample}.1.fq.gz",
        fq_2="work/bam_to_fq/{sample}.2.fq.gz",
        done="work/bam_to_fq/{sample}.txt"
    resources:
        mem_mb=32_000, disk_mb=200_000
    conda:
        "environment.yaml"
    shell:
        """
        samtools fastq -n -1 {output.fq_1} -2 {output.fq_2} {input.bam}
        touch {output.done}
        """

rule align:
    input:
        ref_fa="data/ref/hs38DH.fa",
        ref_fai="data/ref/hs38DH.fa.fai",
        ref_bwt="data/ref/hs38DH.fa.bwt",
        ref_sa="data/ref/hs38DH.fa.sa",
        ref_ann="data/ref/hs38DH.fa.ann",
        ref_amb="data/ref/hs38DH.fa.amb",
        ref_pac="data/ref/hs38DH.fa.pac",
        fq_1="work/bam_to_fq/{sample}.1.fq.gz",
        fq_2="work/bam_to_fq/{sample}.2.fq.gz",
    output:
        bam="work/align/{sample}.bam",
        done="work/align/{sample}.txt"
    resources:
        mem_mb=32_000, disk_mb=200_000
    threads:
        16
    conda:
        "environment.yaml"
    shell:
        """
        bwa mem -t {threads} {input.ref_fa} {input.fq_1} {input.fq_2} \
          | samtools view -b - > {output.bam}

        touch {output.done}
        """

rule sort:
    input:
        bam="work/align/{sample}.bam",
    output:
        bam="work/sort/{sample}.bam",
        bai="work/sort/{sample}.bam.bai",
        done="work/sort/{sample}.txt"
    resources:
        mem_mb=32_000, disk_mb=200_000
    threads:
        2
    conda:
        "environment.yaml"
    shell:
        """
        samtools sort --threads={threads} -m 7000M --no-PG -T {output.bam}.tmp -o {output.bam} {input.bam}
        samtools index {output.bam}
        touch {output.done}
        """

# vim: filetype=snakemake tabstop=4 shiftwidth=4 softtabstop=4 expandtab
