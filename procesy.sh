#!/bin/bash
# Autor: Dominika Maciejewska
# Informatyka Medyczna, stopień I, semestr 3, 2025/2026 

nano another.c

#include <stdio.h>
#include <unistd.h>

int main() {
    printf("Hello, I'm another program! My PID = %d\n", getpid());
    fflush(stdout); 
    getchar();     
    return 0;
}

nano exec.c
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

int main() {
    printf("Hello, I'm exec program! My PID = %d\n", getpid());
    fflush(stdout);
    execl("./another", "another", NULL);

    perror("exec error");
    printf("Hello, I'm again exec program! My PID = %d\n", getpid());
    fflush(stdout);
    return 0;
}

nano system.c

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

int main() {
    printf("Hello, I'm system program! My PID = %d\n", getpid());
    fflush(stdout);
    system("./another");

    printf("Hello, I'm again system program! My PID = %d\n", getpid());
    fflush(stdout);
    return 0;
}


kompilacja:
gcc -o another another.c
gcc -o exec exec.c
gcc -o system system.c

ls -l another exec system

./another

-drugi terminal:
ps -p 12345 -o pid,ppid,cmd

./exec

ps -o pid,ppid,cmd --forest | grep -E "exec|another"


./system

ps -o pid,ppid,cmd --forest | grep -E "system|another|sh -c"

mv another another.tmp
./exec
./system
mv another.tmp another

drugi terminal:
ps -o pid,ppid,cmd --forest | grep -E "system|another|sh -c" -n



another:
#include <stdio.h>
#include <unistd.h>

int main() {
    printf("Hello, I'm another program! My PID = %d\n", getpid());
    fflush(stdout);
    getchar();   // ważne, żeby proces żył!
    return 0;
}

exec:
#include <stdio.h>
#include <unistd.h>

int main() {
    printf("Hello, I'm exec program! My PID = %d\n", getpid());
    fflush(stdout);

    execl("./another", "another", NULL);

    printf("Hello, I'm again exec program! My PID = %d\n", getpid());
    fflush(stdout);

    return 0;
}

system:
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

int main() {
    printf("Hello, I'm system program! My PID = %d\n", getpid());
    fflush(stdout);

    system("./another");

    printf("Hello, I'm again system program! My PID = %d\n", getpid());
    fflush(stdout);

    return 0;
}
