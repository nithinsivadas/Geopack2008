project('Geopack08', 'fortran',
  default_options : ['default_library=static', 'buildtype=release'])

geopack32_lib = library('geopack08_32', 'GEOPACK-2008.f')
geopack64_lib = library('geopack08_64', 'GEOPACK-2008_dp.f')

t96_lib = library('t96', 'T96.f')

t96_exe = executable('run_T96', 'run_T96.f',
  link_with: [geopack32_lib, t96_lib])

# should use realistic inputs instead
test('T96', t96_exe,
  args: ['2010', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14'],
  timeout: 10)

example1_exe = executable('example1', 'example1.f',
  link_with: [geopack32_lib, t96_lib])

# should use realistic inputs instead
test('example1', example1_exe,
  args: ['2010', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14'],
  timeout: 10)