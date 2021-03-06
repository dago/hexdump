/*****************************************************************************

hexdump.c -- generate CP/M style hex dumps

*****************************************************************************/

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <locale.h>
#include <stdlib.h>
#include <stdbool.h>

#define DEFWIDTH	16		/* Default # chars to show per line */
#define MAXWIDTH	128		/* Maximum # of bytes per line	*/
#define HEXPERBYTE	3		/* Two hex characters plus space */
#define HEXOVERHEAD	7		/* fixed overhead per line of hex */

static long	linebytes = DEFWIDTH;	/* # of bytes to print per line */
static bool	eflag = false;		/* display ebcdic if true */
static bool	cflag = false;		/* show printables as ASCII if true */
static bool	gflag = false;		/* suppress mid-page gutter if true */
static long	start = 0L;		/* file offset to start dumping at */
static long	length = 0L;		/* if nz, how many chars to dump */

static char ebcdic[] =
{
/*        0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F  */
/* 40 */ ' ','.','.','.','.','.','.','.','.','.','[','.','<','(','+','!',
/* 50 */ '&','.','.','.','.','.','.','.','.','.',']','$','*',')',';','^',
/* 60 */ '-','/','.','.','.','.','.','.','.','.','|',',','%','_','>','?',
/* 70 */ '.','.','.','.','.','.','.','.','.','`',':','#','@','\'','=','"',
/* 80 */ '.','a','b','c','d','e','f','g','h','i','.','.','.','.','.','.',
/* 90 */ '.','j','k','l','m','n','o','p','q','r','.','.','.','.','.','.',
/* A0 */ '.','~','s','t','u','v','w','x','y','z','.','.','.','.','.','.',
/* B0 */ '.','.','.','.','.','.','.','.','.','.','.','.','.','.','.','.',
/* C0 */ '{','A','B','C','D','E','F','G','H','I','.','.','.','.','.','.',
/* D0 */ '}','J','K','L','M','N','O','P','Q','R','.','.','.','.','.','.',
/* E0 */ '\\','.','S','T','U','V','W','X','Y','Z','.','.','.','.','.','.',
/* F0 */ '0','1','2','3','4','5','6','7','8','9','.','.','.','.','.','.',
};

static void dumpfile(FILE *f)
/* dump a single, specified file -- stdin if filename is NULL */
{
    int     ch = '\0';		/* current character            */
    char    ascii[MAXWIDTH+3];	/* printable ascii data         */
    int     i = 0;		/* counter: # bytes processed	*/
    int     ai = 0;		/* index into ascii[]           */
    int     offset = 0;		/* byte offset of line in file  */
    int     hpos;		/* horizontal position counter  */
    long    fstart = start;
    long    flength = length;
    char    *specials = "\b\f\n\r\t";
    char    *escapes = "bfnrt";
    char    *cp;

    do {
	ch = getc(f);

	if (ch != EOF)
	{
	    if (start && fstart-- > 0)
		continue;

	    if (length && flength-- <= 0)
		ch = EOF;
	}

	if (ch != EOF)
	{
	    if (i++ % linebytes == 0)
	    {
		(void) printf("%04x ", offset);
		offset += linebytes;
		hpos = 5;
	    }

	    /* output one space for the mid-page gutter */
	    if (!gflag)
		if ((i - 1) % (linebytes / 2) == 0)
		{
		    (void) putchar(' ');
		    hpos++;
		    ascii[ai++] = ' ';
		}

	    /* dump the indicated representation of a character */
	    if (eflag)		/* we're dumping EBCDIC (blecch!) */
	    {
		ascii[ai] = (ch >= 0x40) ? ebcdic[ch - 0x40] : '.';

		if (cflag && (ascii[ai] != '.' || ch == ebcdic['.']))
		    (void) printf("%c  ", ascii[ai]);
		else if (cflag && ch && (cp = strchr(specials, ch)))
		    (void) printf("\\%c ", escapes[cp - specials]);
		else
		    (void) printf("%02x ", ch);
	    }
	    else		/* we're dumping ASCII */
	    {
		ascii[ai] = (isprint (ch) || ch == ' ') ? ch : '.';

		if (cflag && (isprint(ch) || ch == ' '))
		    (void) printf("%c  ", ch);
		else if (cflag && ch && (cp = strchr(specials, ch)))
		    (void) printf("\\%c ", escapes[cp - specials]);
		else
		    (void) printf("%02x ", ch);
	    }

	    /* update counters and things */
	    ai++;
	    hpos += HEXPERBYTE;
	}

	/* At end-of-line or EOF, show ASCII or EBCDIC version of data. */
	if (i && (ch == EOF || (i % linebytes == 0)))
	{
	    if (!cflag)
	    {
		while (hpos < linebytes * HEXPERBYTE + HEXOVERHEAD)
		{
		    hpos++;
		    (void) putchar(' ');
		}

		ascii[ai] = '\0';
		(void) printf("%s", ascii);
	    }

	    if (ch != EOF || (i % linebytes != 0))
		(void) putchar('\n');
	    ai = 0;		/* reset counters */
	}
    } while
	(ch != EOF);
}

static long getoffs(char *cp)
/* fetch decimal or hex integer to be used as file start or offset */
{
    bool foundzero = false;
    long value = 0;
    int base = 0;
    char *hexdigits = "0123456789abcdefABCDEF";

    for (; *cp; cp++)
	if (*cp == '0')
	    foundzero = true;
	else if (isdigit(*cp))
	{
	    base = 10;
	    break;
	}
        else if (*cp == 'x' || *cp == 'X' || *cp == 'h' || *cp == 'H')
	{
	    base = 16;
	    cp++;
	    break;
	}
        else
	    return(-1L);

    if (base == 0)
	if (foundzero)
	    base = 10;
        else
	    return(-1L);

    if (base == 10)
    {
	for (; *cp; cp++)
	    if (isdigit(*cp))
		value = value * 10 + (*cp - '0');
	    else
		return(-1L);
    }
    else
    {
	for (; *cp; cp++)
	    if (strchr(hexdigits, *cp))
		value = value*16 + (strchr(hexdigits, tolower(*cp))-hexdigits);
	    else
		return(-1L);
    }

    return(value);
}

main(int argc, char **argv)
{
    FILE    *infile;	    /* file pointer input file */
    int	    dumpcount = 0;  /* count of files dumped so far */
    char    *cp;

    setlocale (LC_CTYPE, "");

    for (argv++, argc--; argc > 0; argv++, argc--)
    {
	char s = **argv;

	if (s == '-' || s == '+')
	{
	    int	c = *++*argv;

	    switch (c)
	    {
	    case 'V':
		printf("hex " RELEASE " by Eric S. Raymond.\n");
		exit(0);

	    case 'e': eflag = (s == '-'); continue;
	    case 'c': cflag = (s == '-'); continue;
	    case 'g': gflag = (s == '-'); continue;

	    case 's':
		if ((*argv)[1])
		    (*argv)++;
		else
		    argc--, argv++;
		if (s == '-' && argc >= 0)
		{
		    if (cp = strchr(*argv, ','))
			*cp++ = '\0';
		    if ((start = getoffs(*argv)) == -1L)
		    {
			(void) fputs("hexdump: start offset no good\n", stderr);
			exit(0);
		    }

		    if (cp)
			if ((length = getoffs(cp)) == -1L)
			{
			    (void) fputs("hexdump: length no good\n", stderr);
			    exit(0);
			}
		}
		else
		    start = length = 0L;
		continue;

	    case '\0':
	        infile = stdin;
		break;

	    case 'w':
		if ((*argv)[1])
		    (*argv)++;
		else
		    argc--, argv++;
		if ((linebytes = getoffs(*argv)) == -1L || linebytes > MAXWIDTH)
		{
		    (void) fputs("hexdump: line width no good\n", stderr);
		    exit(0);
		}
		if (linebytes % 2)
		    gflag = true;
	        continue;

	    default:
	        (void) fprintf(stderr, "hexdump: no such option as %s\n", *argv);
		exit(0);
	    }
	}
	else if ((infile = fopen(*argv, "rb")) == NULL)
	{
	    (void) fprintf(stderr, "hexdump: cannot open %s\n", *argv);
	    exit(1);
	}

	if (dumpcount > 0 || argc > 1)
	    if (infile == stdin)
		(void) printf("---- <Standard input> ----\n");
	    else
		(void) printf("---- %s ----\n", *argv);
	dumpfile(infile);
	dumpcount++;
	if (infile != stdin)
	    (void) fclose(infile);
    }

    if (dumpcount == 0)
	dumpfile(stdin);
    return(0);
}

/* hexdump.c ends here */
