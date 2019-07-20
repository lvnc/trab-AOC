#include <stdio.h>
#include <stdlib.h>

int fatorial (int numero)
{
	int i;
	int fat=1;

	if (numero != 0)
	{
		for (i = 1; i <= numero; i++)
		{ 
			fat = fat * i;
		}
	}

	return fat;
}


int main()
{	
	printf("Analise Combinatoria\n\n");

	int n, r, combinacao;
	
	printf("Insira o numero total de elementos (n): ");
	scanf("%d", &n);
	
	if (n > 8) {

		printf("Overflow. Numero maior que 8. \n\n");

	}
	else {

		printf("Insira o tamanho do subconjunto (r): ");
		scanf("%d", &r);

		combinacao = fatorial(n) / (fatorial(r) * fatorial(n - r));

		printf("Resultado da combinacao: %d \n\n", combinacao);

	}

	

	system("pause");

	return 0;
}