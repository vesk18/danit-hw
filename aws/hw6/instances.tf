resource "aws_key_pair" "hw21_key" {
  key_name   = "hw21-key"
  public_key = file("/Users/hugo/vs-code/hw21/test1.pub")
}

resource "aws_instance" "web" {
  count         = 2
  ami           = "ami-0f34c5ae932e6f0e4"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  key_name      = aws_key_pair.hw21_key.key_name
  vpc_security_group_ids = [aws_security_group.instance.id]

  tags = {
    Name = "hw21-web-${count.index + 1}"
  }
}

resource "local_file" "ansible_inventory" {
  filename = "/Users/hugo/vs-code/hw21/inventory.ini"
  content = templatefile("${path.module}/inventory.tpl", {
    instances = aws_instance.web.*.public_ip
    key_path  = "/Users/hugo/vs-code/hw21/test1.pem"
  })
}