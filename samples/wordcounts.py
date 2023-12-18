import argparse
import logging
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions

def run(input_path, output_path):
    options = PipelineOptions([
        "--runner=SparkRunner",
    ])
    with beam.Pipeline(options=options) as p:
        (p
         | 'ReadFromText' >> beam.io.ReadFromText(input_path)
         | 'SplitWords' >> beam.FlatMap(lambda x: x.split())
         | 'CountWords' >> beam.combiners.Count.PerElement()
         | 'FormatResults' >> beam.Map(lambda word_count: f"{word_count[0]}: {word_count[1]}")
         | 'WriteToText' >> beam.io.WriteToText(output_path)
        )

if __name__ == "__main__":
    logging.getLogger().setLevel(logging.INFO)
    
    parser = argparse.ArgumentParser(description="Apache Beam pipeline processing text files")
    parser.add_argument('--input', required=True, help="Input file path (e.g., 's3://path/to/input.txt')")
    parser.add_argument('--output', required=True, help="Output file path (e.g., 's3://path/to/output')")

    args = parser.parse_args()

    run(args.input, args.output)
