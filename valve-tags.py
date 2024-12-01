#!/usr/bin/env python3
from pathlib import Path
from subprocess import run
from itertools import product
from argparse import ArgumentParser
from tqdm import tqdm
from multiprocessing import Pool
import json

parser = ArgumentParser()
parser.add_argument( '--fill', action = 'store_true' )
arguments = parser.parse_args()

OPENSCAD = '/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD'
SCAD_FILE = Path( __file__ ).with_name( 'valve-tag.scad' )
LOCATED_LABELS = (
  'Hose Bib',
  'Sprinklers',
)
LOCATIONS = (
    'Front',
    'Rear',
    'Side',
    'Front Yard',
    'Back Yard',
    'Left Side',
    'Right Side',
    'Garden',
)
LOCATIONLESS_LABELS = (
  'Cold Water',
  'Furnace',
  'Gas',
  # 'Hot Water Heater',
  'Hot Water',
  'Humidifier',
  'Main Water',
  'Refrigerator',
)
PRESET_DATA = json.loads( SCAD_FILE.with_suffix( '.json' ).read_text() )
PRESETS = list( PRESET_DATA.get( 'parameterSets', {} ).keys() )

def _make_labels():
    for name in LOCATED_LABELS:
        for location in LOCATIONS:
            yield ( location, name )
    for name in LOCATIONLESS_LABELS:
            yield ( name, )

def make_labels():
    for label in _make_labels():
        yield label
        yield ( *label, 'Shut-Off' )

def make_combinations():
    for preset, label in product( PRESETS, make_labels() ):
        directory = Path( __file__ ).parent / preset
        directory.mkdir( parents=True, exist_ok=True )

        name = ' '.join( label ).lower().replace( ' ', '_' )
        file = directory / f'{name}.stl'

        if arguments.fill and file.exists(): continue # noqa: E701

        args = [
            '-o', str( file ),
            '-p', str( SCAD_FILE.with_suffix( '.json' ) ),
            '-P', preset,
        ]
        for idx, label in enumerate( label ):
            args += [ '-D', f'LABEL{idx+1}="{label}"' ]

        yield args

def make_one( args: list[str] ):
    run(
        [ OPENSCAD, *args, str( SCAD_FILE ) ],
        check = True, capture_output = True, text = True,
    )
    return args

def with_parallelism():
    combinations = list( make_combinations() )
    done = 0
    with Pool( processes = 8 ) as pool:
        for _ in pool.imap_unordered( make_one, combinations ):
            done += 1
            print( f'\r{done} / {len(combinations)}        ', end = '' )

def with_progress():
    combinations = list( make_combinations() )
    for args in tqdm( combinations ):
        make_one( args )

if __name__ == '__main__':
    with_parallelism()
