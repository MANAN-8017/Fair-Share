#include <stdio.h>
#include <stdlib.h>

typedef struct{
    int debtorId;
    int creditorId;
    double amount;
} Transaction;

Transaction transactions[100] = {
    {1, 2, 500},
    {3, 2, 300},
    {3, 4, 200},
    {5, 4, 400},
    {1, 5, 100},
    {2, 5, 250},
    {4, 1, 150} 
};
int size = 7;

void printTransactions(Transaction transactions[], int size){
    printf("\nTransactions:\n");
    for(int i=0;i<size;i++)
        printf("%d -> %d : %.2f\n", transactions[i].debtorId, transactions[i].creditorId, transactions[i].amount);
}

void calculateBalances(double balance[], int maxUsers){
    for(int i=0;i<maxUsers;i++)
        balance[i] = 0;

    for(int i=0;i<size;i++){
        int debtor = transactions[i].debtorId;
        int creditor = transactions[i].creditorId;
        double amount = transactions[i].amount;

        balance[creditor] += amount;
        balance[debtor] -= amount;
    }
}

Transaction simplified[100];
int simplifiedSize = 0;
void simplifyDebts(double balance[], int maxUsers){
    while(1){
        int debtor = -1;
        int creditor = -1;

        double maxDebt = 0;
        double maxCredit = 0;

        for(int i=1;i<maxUsers;i++){
            if(balance[i]< -0.00 && -balance[i]>maxDebt){
                maxDebt = -balance[i];
                debtor = i;
            }
        }

        for(int i=1;i<maxUsers;i++){
            if(balance[i]>0.00 && balance[i]>maxCredit){
                maxCredit = balance[i];
                creditor = i;
            }
        }

        if (debtor == -1 || creditor == -1)
            break;

        double amount;

        if (maxDebt < maxCredit)
            amount = maxDebt;
        else 
            amount = maxCredit;

        simplified[simplifiedSize].creditorId = creditor;
        simplified[simplifiedSize].debtorId = debtor;
        simplified[simplifiedSize].amount = amount;

        simplifiedSize++;

        balance[debtor] += amount;
        balance[creditor] -= amount;
    }
}

void printBalances(double balance[], int maxUsers) {
    printf("\nNet Balances:\n");
    for (int i=1;i<maxUsers;i++)
        printf("User %d : %.2f\n", i, balance[i]);
}

int main() {
    int maxUsers = 6;
    double balance[6];

    printf("ORIGINAL:\n");
    printTransactions(transactions, size);
    calculateBalances(balance, maxUsers);
    printBalances(balance, maxUsers);

    simplifyDebts(balance, maxUsers);
    printf("\nSIMPLIFIED:\n");
    printTransactions(simplified, simplifiedSize);

    return 0;
}