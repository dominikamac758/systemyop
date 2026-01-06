ODBIORCA:
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <time.h>
#include <string.h>

char morse_buffer[10];
int morse_len = 0;

struct timespec last_time = {0};
volatile sig_atomic_t got_signal = 0;
double last_diff = 0;

const char *morse_codes[] = {
    ".-", "-...", "-.-.", "-..", ".", "..-.", "--.", "....", "..", ".---",
    "-.-", ".-..", "--", "-.", "---", ".--.", "--.-", ".-.", "...", "-",
    "..-", "...-", ".--", "-..-", "-.--", "--.."};
const char alphabet[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

void decode_and_print()
{
    if (morse_len == 0)
        return;

    morse_buffer[morse_len] = '\0';

    for (int i = 0; i < 26; i++)
    {
        if (strcmp(morse_buffer, morse_codes[i]) == 0)
        {
            printf("%c", alphabet[i]);
            fflush(stdout);
            morse_len = 0;
            return;
        }
    }

    printf("?");
    fflush(stdout);
    morse_len = 0;
}

void handle_signal(int sig)
{
    struct timespec now;
    clock_gettime(CLOCK_MONOTONIC, &now);

    if (last_time.tv_sec != 0)
    {
        last_diff =
            (now.tv_sec - last_time.tv_sec) +
            (now.tv_nsec - last_time.tv_nsec) / 1e9;
        got_signal = 1;
    }

    last_time = now;
}

int main()
{
    printf("PID odbiorcy: %d\n", getpid());
    printf("Oczekiwanie na sygnały...\n");

    signal(SIGUSR1, handle_signal);

    while (1)
    {
        pause();

        if (!got_signal)
            continue;

        got_signal = 0;

        if (last_diff >= 0.5 && last_diff < 1.5)
        {
            if (morse_len < 9)
                morse_buffer[morse_len++] = '.';
        }
        else if (last_diff >= 1.5 && last_diff < 2.5)
        {
            if (morse_len < 9)
                morse_buffer[morse_len++] = '-';
        }
        else if (last_diff >= 2.5 && last_diff < 3.5)
        {
            decode_and_print();
        }
        else if (last_diff >= 3.5)
        {
            decode_and_print();
            printf(" ");
            fflush(stdout);
        }
    }
}

NADAWCA:
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <ctype.h>

const char *morse_codes[] = {
    ".-", "-...", "-.-.", "-..", ".", "..-.", "--.", "....", "..", ".---",
    "-.-", ".-..", "--", "-.", "---", ".--.", "--.-", ".-.", "...", "-",
    "..-", "...-", ".--", "-..-", "-.--", "--.."};

void send_pulse(pid_t pid, int duration)
{
    kill(pid, SIGUSR1);
    sleep(duration);
    usleep(100000); // krótka przerwa bezpieczeństwa
}

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        printf("Użycie: %s <PID_ODBiorcy>\n", argv[0]);
        return 1;
    }

    pid_t target_pid = atoi(argv[1]);
    char input[100];

    printf("Połączono z PID %d\n", target_pid);

    while (1)
    {
        printf("Wpisz tekst (A–Z, spacje): ");
        fflush(stdout);

        if (!fgets(input, sizeof(input), stdin))
            break;

        for (int i = 0; input[i] != '\0'; i++)
        {
            char c = toupper(input[i]);

            if (c >= 'A' && c <= 'Z')
            {
                const char *code = morse_codes[c - 'A'];
                printf("Wysyłam: %c [%s]\n", c, code);

                for (int j = 0; code[j] != '\0'; j++)
                {
                    if (code[j] == '.')
                        send_pulse(target_pid, 1); // kropka
                    else
                        send_pulse(target_pid, 2); // kreska
                }
                send_pulse(target_pid, 3); // koniec znaku
            }
            else if (c == ' ')
            {
                send_pulse(target_pid, 4); // spacja
            }
        }
    }
    return 0;
}

nadawca:
bierze PID odbiorcy z linii poleceń,
czyta tekst z klawiatury,
zamienia litery na alfabet Morse’a,
wysyła sygnał SIGUSR1,
długością przerwy (sleep) koduje kropki i kreski


nano odbiorca.c
nano nadawca.c

gcc odbiorca.c -o odbiorca
gcc nadawca.c -o nadawca

Terminal 1: ./odbiorca
Terminal 2: ./nadawca + PID od odbiorcy

#include <stdio.h>      // printf(), fgets() – wejście/wyjście
#include <stdlib.h>     // atoi() – zamiana tekstu na liczbę
#include <unistd.h>     // sleep(), usleep() – funkcje systemowe UNIX
#include <signal.h>     // kill(), SIGUSR1 – obsługa sygnałów
#include <string.h>     // operacje na napisach (tu pośrednio)
#include <ctype.h>      // toupper() – zamiana liter na wielkie

/* 
 Tablica kodów alfabetu Morse’a.
 Indeks 0  -> 'A'
 Indeks 1  -> 'B'
 ...
 Indeks 25 -> 'Z'
*/
const char *morse_codes[] = {
    ".-",    // A
    "-...",  // B
    "-.-.",  // C
    "-..",   // D
    ".",     // E
    "..-.",  // F
    "--.",   // G
    "....",  // H
    "..",    // I
    ".---",  // J
    "-.-",   // K
    ".-..",  // L
    "--",    // M
    "-.",    // N
    "---",   // O
    ".--.",  // P
    "--.-",  // Q
    ".-.",   // R
    "...",   // S
    "-",     // T
    "..-",   // U
    "...-",  // V
    ".--",   // W
    "-..-",  // X
    "-.--",  // Y
    "--.."   // Z
};

/*
 Funkcja wysyłająca pojedynczy impuls Morse’a.
 pid      – PID procesu odbiorcy
 duration – czas trwania impulsu (w sekundach)
*/
void send_pulse(pid_t pid, int duration)
{
    kill(pid, SIGUSR1);     // wysłanie sygnału SIGUSR1 do odbiorcy
    sleep(duration);       // czas trwania impulsu:
                           // 1s – kropka
                           // 2s – kreska
                           // 3s – koniec litery
                           // 4s – spacja
    usleep(100000);        // krótka przerwa (0.1s), aby sygnały się nie zlewały
}

int main(int argc, char *argv[])
{
    /*
     argc – liczba argumentów programu
     argv – tablica argumentów:
     argv[0] – nazwa programu
     argv[1] – PID odbiorcy
    */

    // Sprawdzenie poprawnej liczby argumentów
    if (argc != 2)
    {
        printf("Użycie: %s <PID_ODBiorcy>\n", argv[0]);
        return 1;          // zakończenie programu z błędem
    }

    // Zamiana PID odbiorcy z tekstu na liczbę
    pid_t target_pid = atoi(argv[1]);

    // Bufor na tekst wpisany przez użytkownika
    char input[100];

    printf("Połączono z PID %d\n", target_pid);

    // Główna pętla programu – działa bez końca
    while (1)
    {
        printf("Wpisz tekst (A–Z, spacje): ");
        fflush(stdout);    // wymusza natychmiastowe wypisanie tekstu

        // Wczytanie linii tekstu z klawiatury
        if (!fgets(input, sizeof(input), stdin))
            break;         // zakończenie programu (np. CTRL+D)

        // Przetwarzanie każdego znaku z osobna
        for (int i = 0; input[i] != '\0'; i++)
        {
            // Zamiana znaku na wielką literę
            char c = toupper(input[i]);

            // Jeśli znak to litera A–Z
            if (c >= 'A' && c <= 'Z')
            {
                /*
                 Obliczenie indeksu litery:
                 'A' - 'A' = 0
                 'B' - 'A' = 1
                 ...
                */
                const char *code = morse_codes[c - 'A'];

                // Informacyjne wypisanie wysyłanej litery i jej kodu
                printf("Wysyłam: %c [%s]\n", c, code);

                // Wysyłanie każdej kropki i kreski
                for (int j = 0; code[j] != '\0'; j++)
                {
                    if (code[j] == '.')
                        send_pulse(target_pid, 1); // kropka – 1 sekunda
                    else
                        send_pulse(target_pid, 2); // kreska – 2 sekundy
                }

                // Przerwa oznaczająca koniec litery
                send_pulse(target_pid, 3);
            }
            // Jeśli znak to spacja
            else if (c == ' ')
            {
                // Dłuższa przerwa oznaczająca spację między wyrazami
                send_pulse(target_pid, 4);
            }
        }
    }

    return 0; // poprawne zakończenie programu
}

#include <stdio.h>      // printf(), fflush()
#include <stdlib.h>     // ogólne funkcje, np. NULL
#include <unistd.h>     // pause()
#include <signal.h>     // obsługa sygnałów (SIGUSR1)
#include <time.h>       // clock_gettime()
#include <string.h>     // strcmp()

/* 
 Bufor przechowujący aktualnie odbierany znak w kodzie Morse’a.
 Maksymalnie 9 znaków + '\0' = 10.
*/
char morse_buffer[10];
int morse_len = 0;      // aktualna liczba kropek i kresek w buforze

/* 
 Przechowuje czas ostatniego odebranego sygnału.
 Potrzebny do obliczenia odstępu czasu między impulsami.
*/
struct timespec last_time = {0};

/* 
 Flaga sygnalizująca głównej pętli, że handler odebrał sygnał.
 volatile sig_atomic_t → bezpieczne w obsłudze sygnałów
*/
volatile sig_atomic_t got_signal = 0;

/* 
 Różnica czasu (w sekundach) między dwoma sygnałami.
 Na podstawie tej wartości rozpoznajemy kropki, kreski, koniec litery i spacje.
*/
double last_diff = 0;

/* Tablica kodów Morse’a dla liter A–Z */
const char *morse_codes[] = {
    ".-", "-...", "-.-.", "-..", ".", "..-.", "--.", "....", "..", ".---",
    "-.-", ".-..", "--", "-.", "---", ".--.", "--.-", ".-.", "...", "-",
    "..-", "...-", ".--", "-..-", "-.--", "--.."
};

/* Tablica liter odpowiadających kodom Morse’a */
const char alphabet[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

/* 
 Funkcja dekodująca znak z bufora Morse’a i wypisująca literę.
 Jeśli kod nie pasuje do żadnej litery, wypisuje znak '?'
*/
void decode_and_print()
{
    if (morse_len == 0)   // jeśli bufor pusty, nic nie robimy
        return;

    morse_buffer[morse_len] = '\0';  // kończymy napis

    // szukamy litery odpowiadającej kodowi
    for (int i = 0; i < 26; i++)
    {
        if (strcmp(morse_buffer, morse_codes[i]) == 0)
        {
            printf("%c", alphabet[i]);   // wypisujemy literę
            fflush(stdout);              // wymuszamy natychmiastowy wydruk
            morse_len = 0;               // czyścimy bufor
            return;
        }
    }

    // jeśli kod nie pasuje, wypisujemy '?'
    printf("?");
    fflush(stdout);
    morse_len = 0;
}

/* 
 Handler sygnału SIGUSR1.
 Wywoływany automatycznie, gdy przyjdzie sygnał od nadawcy.
*/
void handle_signal(int sig)
{
    struct timespec now;
    clock_gettime(CLOCK_MONOTONIC, &now);  // aktualny czas monotoniczny

    if (last_time.tv_sec != 0)   // jeśli to nie pierwszy sygnał
    {
        // obliczamy różnicę czasu między sygnałami w sekundach
        last_diff =
            (now.tv_sec - last_time.tv_sec) +           // różnica w sekundach
            (now.tv_nsec - last_time.tv_nsec) / 1e9;   // różnica w nanosekundach
        got_signal = 1;   // ustawiamy flagę informującą pętlę główną
    }

    last_time = now;       // aktualny czas staje się "ostatnim"
}

int main()
{
    // wypisanie PID procesu – potrzebne nadawcy do wysyłania sygnałów
    printf("PID odbiorcy: %d\n", getpid());
    printf("Oczekiwanie na sygnały...\n");

    // podłączenie handlera do sygnału SIGUSR1
    signal(SIGUSR1, handle_signal);

    // główna pętla programu
    while (1)
    {
        pause();    // proces "usypia", czeka na sygnał

        if (!got_signal)    // jeśli handler nie ustawił flagi, wracamy do oczekiwania
            continue;

        got_signal = 0;     // resetujemy flagę

        // interpretacja różnicy czasu między sygnałami

        if (last_diff >= 0.5 && last_diff < 1.5)
        {
            // kropka (ok. 1 sekundy)
            if (morse_len < 9)
                morse_buffer[morse_len++] = '.';
        }
        else if (last_diff >= 1.5 && last_diff < 2.5)
        {
            // kreska (ok. 2 sekundy)
            if (morse_len < 9)
                morse_buffer[morse_len++] = '-';
        }
        else if (last_diff >= 2.5 && last_diff < 3.5)
        {
            // koniec litery – dekodujemy aktualny bufor
            decode_and_print();
        }
        else if (last_diff >= 3.5)
        {
            // koniec wyrazu – dekodujemy bufor i wypisujemy spację
            decode_and_print();
            printf(" ");
            fflush(stdout);
        }
    }
}

