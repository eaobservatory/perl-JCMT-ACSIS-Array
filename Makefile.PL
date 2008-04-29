use ExtUtils::MakeMaker;
WriteMakefile(
  'NAME'         => 'JCMT::ACSIS::Array',
  'VERSION_FROM' => 'Array.pm',
  'dist'         => { COMPRESS => "gzip -9f" }
  ); 
