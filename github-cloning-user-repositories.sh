github_username=$1

jq=C:/jq-win64.exe

api_result=$(curl "https://api.github.com/users/${github_username}/repos")

date_time=`date +"%Y-%m-%d-%H-%M-%S"`

main_path="github-${date_time}"

mkdir $main_path
cd $main_path

$jq -c '.[]' <<< $api_result | while read i; do
    repository_path_name=`echo $i | $jq '.name' -r`
    repository_ssh_url=`echo $i | $jq '.ssh_url' -r`
    
    mkdir ${repository_path_name}
    cd ${repository_path_name}
    
    git clone ${repository_ssh_url} .
    
    cd ..
done

ls

cd ..
