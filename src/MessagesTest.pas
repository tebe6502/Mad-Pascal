unit MessagesTest;


interface

procedure Test;

implementation

uses Asserts, Messages;

procedure Test;
var
  message: TMessage;
begin

  Messages.Initialize;
  message := TMessage.Create(TErrorCode.IllegalExpression,
    'A={0} B={1} C={2} D={3} E={4} F={5} G={6} H={7} I={8} J={9}', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J');
  AssertEquals(message.GetText(), 'A=A B=B C=C D=D E=E F=F G=G H=H I=I J=J');
  Messages.WritelnMsg;

end;

end.
