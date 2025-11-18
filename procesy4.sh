#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>

void handler(int sig, siginfo_t *info, void *ucontext) {
    printf("Odebrano sygnał: %d (%s)", sig, strsignal(sig));
    if(info) {
        printf(", PID nadawcy: %d, UID: %d\n", info->si_pid, info->si_uid);
    } else {
        printf("\n");
    }
    fflush(stdout);
}

int main() {
    struct sigaction sa;
    sa.sa_flags = SA_SIGINFO;  // pozwala na przekazanie info o nadawcy
    sa.sa_sigaction = handler;
    sigemptyset(&sa.sa_mask);  // nie blokujemy żadnych innych sygnałów

    // Zainstaluj handler dla kilku sygnałów testowych
    sigaction(SIGINT, &sa, NULL);
    sigaction(SIGTERM, &sa, NULL);
    sigaction(SIGHUP, &sa, NULL);
    sigaction(SIGUSR1, &sa, NULL);
    sigaction(SIGUSR2, &sa, NULL);

    printf("PID catchsignal: %d\n", getpid());
    printf("Oczekiwanie na sygnały...\n");

    // nieskończona pętla oczekiwania na sygnał
    while(1) {
        pause(); // czeka na sygnał
    }

    return 0;
}

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <errno.h>
#include <unistd.h>
#include <dirent.h>

int main(int argc, char *argv[]) {
    if(argc != 3) {
        fprintf(stderr, "Użycie: %s <PID|nazwa_procesu> <sygnał>\n", argv[0]);
        return 1;
    }

    char *target = argv[1];
    char *sigstr = argv[2];
    int sig;

    // jeśli sygnał jest numerem
    char *end;
    sig = strtol(sigstr, &end, 10);
    if(*end != '\0') {
        // jeśli nie liczba, spróbuj z nazwy sygnału, np. "SIGTERM"
        if(strncmp(sigstr,"SIG",3) == 0) {
            if(strcmp(sigstr,"SIGINT")==0) sig = SIGINT;
            else if(strcmp(sigstr,"SIGTERM")==0) sig = SIGTERM;
            else if(strcmp(sigstr,"SIGHUP")==0) sig = SIGHUP;
            else if(strcmp(sigstr,"SIGUSR1")==0) sig = SIGUSR1;
            else if(strcmp(sigstr,"SIGUSR2")==0) sig = SIGUSR2;
            else {
                fprintf(stderr, "Nieznany sygnał: %s\n", sigstr);
                return 1;
            }
        } else {
            fprintf(stderr, "Nieprawidłowy sygnał: %s\n", sigstr);
            return 1;
        }
    }

    // jeśli target jest numerem PID
    pid_t pid = strtol(target, &end, 10);
    if(*end == '\0') {
        if(kill(pid, sig) != 0) {
            perror("kill");
        } else {
            printf("Wysłano sygnał %d (%s) do PID=%d\n", sig, strsignal(sig), pid);
        }
        return 0;
    }

    // jeśli target jest nazwą procesu – przeszukaj /proc
    DIR *proc = opendir("/proc");
    if(!proc) { perror("opendir /proc"); return 1; }
    struct dirent *entry;
    while((entry = readdir(proc)) != NULL) {
        pid_t pid2 = strtol(entry->d_name, &end, 10);
        if(*end != '\0') continue; // nie PID
        char path[256];
        snprintf(path,sizeof(path),"/proc/%d/comm", pid2);
        FILE *f = fopen(path,"r");
        if(!f) continue;
        char name[128];
        fgets(name,sizeof(name),f);
        fclose(f);
        name[strcspn(name,"\n")] = 0;
        if(strcmp(name,target)==0) {
            if(kill(pid2, sig) != 0) perror("kill");
            else printf("Wysłano sygnał %d (%s) do PID=%d (%s)\n", sig, strsignal(sig), pid2, name);
        }
    }
    closedir(proc);

    return 0;
}
