# Push Reciver
- proxy between Gitlab and Jenkins
- storage and accumulate data from Jenkins

### Version 0.0.1

### Instalation
1. configure hook in gitlab
2. configure jobs in jenkins

### Usage
1. push your code to gitlab and hook get info about commit to reciver
2. in index_handler.erl we parse info from gitlab (repository, user, etc..)
3. we handle data from 2. and initiate launch job in jenkins

4. save_handler recive and accumulate data from jenkins
5. load_handler return accumulated data from 4. and clean storage.