#!/bin/bash

#template
read -r -d '' MANIFEST_STRUCT << EOM
typedef struct
{
  const char * filename;
  const char * filedata;
  int length;
} PACKED_FILE;


// Packed Files
EOM

read -r -d '' MANIFEST_PRE << EOM

static const PACKED_FILE static_files_manifest[] =
{
EOM

read -r -d '' MANIFEST_POST << EOM
  {NULL,NULL,NULL}
};
EOM

#Clear out static file.
echo "$MANIFEST_STRUCT" > static.h

#Collect up our static documents
find . -type f -not -name "*.h" -not -name "*.sh"  -print0 | while read -r -d '' file_name
do
  echo "Packing $file_name"
  #Convert to C array and append to packed file.
  #Make sure files terminate with a 0 so they're valud strings.
  #Make sure the array type is static const.
  #Append to static files
  xxd -i $file_name | sed --expression 's/unsigned/static const/g' | cat >> static.h
done

# Build manifest
echo >> static.h
echo >> static.h
echo "// Manifest Strings" >> static.h
echo >> static.h
#const strings for filenames.
for f in `cat static.h | grep "static const char __" | awk '{print $4}' | sed "s/\[\]//"`
do
  FNAME=`echo $f | sed "s/__//" | sed "s/_/./g" | cat`
  CNAME=$f
  printf "static const char _filename%s[] = \"%s\"; \n" "$CNAME" "$FNAME" >>static.h
done


echo >> static.h
echo >> static.h
echo "// Manifest" >> static.h
echo >> static.h
echo "$MANIFEST_PRE" >> static.h

for f in `cat static.h | grep "static const char __" | awk '{print $4}' | sed "s/\[\]//"`
do

  CNAME=$f
  printf "\t{_filename%s,\t %s,\t %s_len}, \n" "$CNAME" "$CNAME" "$CNAME"  >>static.h
done

echo "$MANIFEST_POST" >> static.h