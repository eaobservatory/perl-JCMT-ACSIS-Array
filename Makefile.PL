use ExtUtils::MakeMaker;
WriteMakefile(
  'NAME'         => 'JCMT::ACSIS::Array',
  'VERSION_FROM' => 'Array.pm',
  'PREREQ_PM'    => { Test::Exception => 0 },
  'dist'         => { COMPRESS => "gzip -9f" }
  ); 
